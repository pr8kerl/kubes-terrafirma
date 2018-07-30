# Building the k8s base vm

## Notes for CentOS 7

```
yum install docker
systemctl enable docker

# configure docker cgroupfs cgroupdriver

sed -i -e 's/systemd/cgroupfs/g' /etc/systemd/system/multi-user.target.wants/docker.service

# ensure vsphere cloud provider is set
# cadvisor port is also re-enabled - kubeadm disables it by default
cat << EOF > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
Environment="KUBELET_DNS_ARGS=--cluster-dns=10.96.0.10 --cluster-domain=cluster.local"
Environment="KUBELET_AUTHZ_ARGS=--authorization-mode=Webhook --client-ca-file=/etc/kubernetes/pki/ca.crt"
Environment="KUBELET_CADVISOR_ARGS=--cadvisor-port=4194"
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd"
Environment="KUBELET_CERTIFICATE_ARGS=--rotate-certificates=true --cert-dir=/var/lib/kubelet/pki"
Environment="KUBELET_EXTRA_ARGS=--cloud-provider=vsphere --cloud-config=/etc/kubernetes/vsphere.conf"
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_AUTHZ_ARGS $KUBELET_CADVISOR_ARGS $KUBELET_CGROUP_ARGS $KUBELET_CERTIFICATE_ARGS $KUBELET_EXTRA_ARGS
EOF

# configure docker log driver
cat << EOF > /etc/sysconfig/docker
OPTIONS='--log-driver=json-file --log-opt max-size=50m --signature-verification=false'
if [ -z "${DOCKER_CERT_PATH}" ]; then
    DOCKER_CERT_PATH=/etc/docker
fi
EOF

# install cfssl etc
curl -sL -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
curl -sL -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod 755 /usr/local/bin/cfssl /usr/local/bin/cfssljson

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl
# check the version - should be latest
kubectl --version

# disable selinux
setenforce 0

systemctl enable kubelet cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

cat <<EOF > /etc/systemd/system/kubelet.service.d/20-cloud-provider.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--cloud-provider=vsphere"
EOF

# remove swap
swapoff -a
vgdisplay -v rootvg
lvremove /dev/rootvg/swap 
vi /etc/fstab

# remove swap from grub
vi /etc/default/grub 
grub2-mkconfig -o /boot/grub2/grub.cfg

dbus-uuidgen --ensure=/etc/machine-id

# whenever you shutdown the base machine, zero the machine id
>/etc/machine-id 

# enable vmware host timesync
vmware-toolbox-cmd timesync enable
vmware-toolbox-cmd timesync status

# cache control plane images
kubeadm config images pull
```
