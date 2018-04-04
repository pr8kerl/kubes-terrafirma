#!/bin/bash

set -e

echo
echo "running kubeadm init"
kubeadm init --config=${k8s_kubeadm_config}

export KUBECONFIG=/etc/kubernetes/admin.conf

PEER_NAME=$(hostname)
if [ "$PEER_NAME" == "${k8s_init_master}" ]
then
  echo "i am not the designated initialisation master - enough of me"
  exit 0
fi

case ${k8s_podnetwork} in
	flannel)
		# flannel
    echo "installing cni network flannel"
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
		;;
	canal)
		# canal
    echo "installing cni network canal"
		kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/canal/rbac.yaml
		kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/canal/canal.yaml
		;;
  calico)
		# calico
    echo "installing cni network calico"
    kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
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
