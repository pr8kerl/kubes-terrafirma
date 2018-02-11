#!/bin/bash

NODE_NAME=$1

if [ -z "$NODE_NAME" ]
then
  echo please provide a node name as an argument.
  exit 1
fi

if [ -f /etc/kubernetes/pki/ca.key ]
then
  chmod 600 /etc/kubernetes/pki/ca.key
  chmod 644 /etc/kubernetes/pki/ca.crt
fi

# hack for adfs access :(
#echo "203.34.100.136	adfs.myob.com.au" >> /etc/hosts

kubeadm join --token=${k8s_bootstrap_token} --node-name $NODE_NAME --discovery-token-unsafe-skip-ca-verification ${k8s_master_ip}:6443
