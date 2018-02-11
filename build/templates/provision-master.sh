#!/bin/bash

if [ -f /etc/kubernetes/pki/ca.key ]
then
  chmod 600 /etc/kubernetes/pki/ca.key
  chmod 644 /etc/kubernetes/pki/ca.crt
  chmod 600 /etc/kubernetes/pki/front-proxy-ca.key
  chmod 644 /etc/kubernetes/pki/front-proxy-ca.crt
fi

# hack for adfs access :(
#echo "203.34.100.136	adfs.myob.com.au" >> /etc/hosts

kubeadm init --config=${k8s_kubeadm_config}

export KUBECONFIG=/etc/kubernetes/admin.conf

case ${k8s_podnetwork} in
	flannel)
		# flannel
    echo "installing cni network flannel"
		kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
		;;
	canal)
		# canal
    echo "installing cni network canal"
		kubectl apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/rbac.yaml
		kubectl apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/canal.yaml
		;;
  calico)
		# calico
    echo "installing cni network calico"
		kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
		;;
  weave)
		# weave
    echo "installing cni network weave"
		kubever=`kubectl version | base64 | tr -d '\n'`
		kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
		;;
  *)
		# flannel
    echo "installing cni network flannel"
		kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
		;;
esac
