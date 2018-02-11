#!/bin/bash

environment=$1
traefik_hostname=traefik.terra.platform.dev.myob.com

if [ -z "${environment}" ]
then
  echo "gimme an environment pls: development | production "
  exit 1
fi


case $environment in
  dev*)
    environment="development"
    traefik_hostname="traefik.terra.platform.dev.myob.com"
    ;;
  prod*)
    environment="development"
    traefik_hostname="traefik.terra.platform.myob.com"
    ;;
  *)
    echo "invalid environment provided: $environment"
    echo "need: development | production"
    exit 1
    ;;
  
esac

context=`kubectl config current-context`
if [ "${context}" != "terra-${environment}" ]
then
    echo "invalid environment provided: $environment"
    echo "need: development | production"
    exit 1
fi

if [ ! -f terra-${environment}.crt -o ! -f terra-${environment}.key ]
then
  echo "gimme some certificate files: terra-${environment}.crt, terra-${environment}.key"
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
      ;;
  esac

done

echo 
echo loading up tls secret
kubectl create secret tls traefik-terra-tls --cert=terra-${environment}.crt --key=terra-${environment}.key -n kube-system
echo
echo storage classes
kubectl apply -f yaml/storage-class-thick.yaml
kubectl apply -f yaml/storage-class-thin.yaml

echo
echo traefik
#echo docker-compose run ktmpl -f yaml/traefik-params-${environment}.yaml yaml/traefik.yaml
#docker-compose run ktmpl -f yaml/traefik-params-${environment}.yaml yaml/traefik.yaml | kubectl apply -f -
ktmpl -f yaml/traefik-params-${environment}.yaml yaml/traefik.yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
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
apiVersion: rbac.authorization.k8s.io/v1beta1
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

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.8.2/src/deploy/recommended/kubernetes-dashboard.yaml

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubernetes-dashboard
  namespace: kube-system

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin

subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kube-system
EOF

TKN_SCRT=`kubectl get secret -n kube-system -o name|grep kubernetes-dashboard-token`

echo
echo dashboard token is:
kubectl describe -n kube-system $TKN_SCRT|grep token:
