#!/bin/bash

clustername=$1
traefik_hostname=traefik.svcs.$clustername

if [ -z "${clustername}" ]
then
  echo "gimme a clustername pls"
  exit 1
fi


context=`kubectl config current-context`
if [ "${context}" != "${clustername}" ]
then
    echo "invalid cluster name provided: $clustername"
    echo "need: ${context}"
    exit 1
fi

if [ ! -f ${clustername}.crt -o ! -f ${clustername}.key ]
then
  echo "gimme some certificate files: ${clustername}.crt, ${clustername}.key"
  exit 1
fi

echo
echo label all nodes as workers
kubectl get node -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'|while read NODE_NAME
do
  
  case $NODE_NAME in
    *master*)
      echo label node $NODE_NAME as master
      echo kubectl label node "role=master" -l "kubernetes.io/hostname=${NODE_NAME}" --overwrite=true
      kubectl label node "role=master" -l "kubernetes.io/hostname=${NODE_NAME}" --overwrite=true
      ;;
    *)
      echo label node $NODE_NAME as worker
      echo kubectl label node "role=worker" -l "kubernetes.io/hostname=${NODE_NAME}" --overwrite=true
      kubectl label node "role=worker" -l "kubernetes.io/hostname=${NODE_NAME}" --overwrite=true
      kubectl label node ${NODE_NAME} node-role.kubernetes.io/node="" --overwrite=true
      ;;
  esac

done

echo
echo storage classes
kubectl apply -f yaml/storage-class-thick.yaml
kubectl apply -f yaml/storage-class-thin.yaml
echo set default StorageClass to thin
kubectl patch storageclass thin --patch '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo 
echo loading up traefik tls secret
kubectl create secret tls traefik-terra-tls --cert=${clustername}.crt --key=${clustername}.key -n kube-system

echo
echo traefik
if [ ! -f yaml/traefik.${clustername}.yaml ]
then
  echo "gimme some traefik parameter files love: yaml/traefik.${clustername}.yaml"
  exit 1
fi
#echo docker-compose run ktmpl -f yaml/traefik-params-${environment}.yaml yaml/traefik.yaml
#docker-compose run ktmpl -f yaml/traefik-params-${environment}.yaml yaml/traefik.yaml | kubectl apply -f -
ktmpl -f yaml/traefik.${clustername}.yaml yaml/traefik.yaml | kubectl apply -f -

echo
echo helm
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: tiller-kube-system
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
EOF

helm init --upgrade --tiller-namespace kube-system --service-account tiller
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: default

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: tiller-default
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
EOF

helm init --upgrade --tiller-namespace default --service-account tiller

echo
echo deploy example kuard app 
for f in ./yaml/kuard/*.yaml; do
  gomplate -f $f -d config=yaml/params-${clustername}.yaml | kubectl apply -f -
done

echo auth
kubectl create ns auth

echo
echo installing oidc-roles for $clustername
gomplate -f yaml/oidc-roles/template.yaml -d config=yaml/params-${clustername}.yaml | kubectl apply -f -

echo
echo installing heapster for $clustername
kubectl apply -f yaml/heapster/heapster.yaml

echo
echo installing dashboard-oidc for $clustername
SECRET=`openssl rand -base64 32`
echo secret=${SECRET} > ./.tmp

kubectl create secret generic kube-dashboard-session-secret -n kube-system --from-env-file=./.tmp

for f in ./yaml/dashboard-oidc/*.yaml; do
  gomplate -f $f -d config=yaml/params-${clustername}.yaml | kubectl apply -f -
done
kubectl rollout status deployment/kubernetes-dashboard-oidc -n kube-system

for f in ./yaml/dex/*.yml; do
  gomplate -f $f -d config=yaml/params-${clustername}.yaml | kubectl apply -f -
done
kubectl rollout status deployment/dex -n auth

echo all done
