# Building the k8s base vm

## Notes for CentOS 7

```
yum install docker
systemctl enable docker
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl start docker

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
```
