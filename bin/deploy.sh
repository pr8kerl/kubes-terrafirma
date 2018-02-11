#!/bin/sh

env=$1

die() {
  echo "error: $*"
  exit 1
}

[[ -z "$env" ]] && die "give me an environment name as an argument please"

echo
echo installing adfs-roles for $env
gomplate -f yaml/adfs-roles/template.yaml -d config=yaml/${env}.datasource | kubectl apply -f -

echo
echo installing heapster for $env
kubectl apply -f yaml/heapster/heapster.yaml

echo
echo installing dashboard-adfs for $env
SECRET=`openssl rand -base64 32`
echo secret=${SECRET} > ./.tmp
kubectl create secret generic kube-dashboard-session-secret --from-env-file=./.tmp
export CHECKSUM=$(md5sum yaml/dashboard-adfs/config-map.yaml | cut -f 1 -d " ")
for f in ./yaml/dashboard-adfs/*.yaml; do
  gomplate -f $f -d config=yaml/${env}.yaml | kubectl apply -f -
done
