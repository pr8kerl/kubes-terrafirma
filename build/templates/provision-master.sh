#!/bin/bash

set -e

if [ -f /etc/kubernetes/pki/ca.key ]
then
  chmod 600 /etc/kubernetes/pki/ca.key
  chmod 644 /etc/kubernetes/pki/ca.crt
  chmod 600 /etc/kubernetes/pki/front-proxy-ca.key
  chmod 644 /etc/kubernetes/pki/front-proxy-ca.crt
fi

# install cfssl for etcd client/peer certs
#curl -sL -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
#curl -sL -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
#chmod 755 /usr/local/bin/cfssl /usr/local/bin/cfssljson

# hack for adfs access :(
#echo "203.34.100.136	adfs.myob.com.au" >> /etc/hosts

PEER_NAME=$(hostname)
PRIVATE_IP=$(ip addr show eth0 | grep -Po 'inet \K[\d.]+')

# install etcd
cwd=`pwd`
cd /tmp
curl -sSL https://github.com/coreos/etcd/releases/download/${etcd_version}/etcd-${etcd_version}-linux-amd64.tar.gz | tar -xz --strip-components=1 -C /usr/local/bin/
rm -rf etcd-${etcd_version}-linux-amd64*
cd $cwd
mkdir -p /var/lib/etcd

echo
echo "generating etcd certificate/key pairs"
cd /etc/kubernetes/pki/etcd/
sed -i 's/HOSTN/'"$PEER_NAME"'/' etcd-csr.json
sed -i 's/IPADDR/'"$PRIVATE_IP"'/' etcd-csr.json
cfssl gencert -ca=../ca.crt -ca-key=../ca.key -config=../ca-config.json -profile=server etcd-csr.json | cfssljson -bare server
cfssl gencert -ca=../ca.crt -ca-key=../ca.key -config=../ca-config.json -profile=peer etcd-csr.json | cfssljson -bare peer

systemctl daemon-reload
systemctl start etcd
systemctl status etcd

