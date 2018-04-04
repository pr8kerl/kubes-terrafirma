#!/bin/bash

set -x

echo args: $*

die()  { echo "ERROR: $1"; exit 1; }

checkrc()  {
 rc=$1
 [[ $rc -ne 0 ]] && die "non-zero return code: $rc"
}

usage() {
  echo
  echo "Checks and creates CA and admin certificates for kubernetes cluster stack.
usage: certs.sh -e <environment>
    -e|--environment   the kubernetes cluster environment to work against
    "
  exit 64
}

genCA() {
  echo "genCA $environment"
}

genAdmin() {
  echo "generate admin certificate for $environment"
  [[ ! -d ./build/tls/${environment} ]] && mkdir ./build/tls/${environment}
  cwd=`pwd`
  cd ./build/tls/${environment}
  cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=../ca-config.json \
    -profile=client \
    ../admin-csr.json | cfssljson -bare admin
  checkrc $?
  cd $cwd
}

genEtcd() {
  echo "generate etcd client certificate for $environment"
  [[ ! -d ./build/tls/${environment} ]] && mkdir ./build/tls/${environment}
  cwd=`pwd`
  cd ./build/tls/${environment}
  cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=../ca-config.json \
    -profile=client \
    ../etcd-csr.json | cfssljson -bare etcd
  checkrc $?
  cd $cwd
}

genServiceAccount() {
  echo "generate service account token keypair for $environment"
  [[ ! -d ./build/tls/${environment} ]] && mkdir ./build/tls/${environment}
  cwd=`pwd`
  cd ./build/tls/${environment}
  openssl genrsa -out sa-key.pem 2048
  checkrc $?
  openssl rsa -in sa-key.pem -pubout -out sa.pem
  checkrc $?
  cd $cwd
}


main() {

  echo "cwd: `pwd`"
  [[ -z $environment ]] && usage
  [[ ! -f ./build/tls/ca-config.json ]] && die "please configure a ca config file: ./build/tls/ca-config.json"
  [[ ! -f ./build/tls/ca-csr.json ]] && die "please configure a ca csr file: ./build/tls/ca-csr.json"
  [[ ! -f ./build/tls/admin-csr.json ]] && die "please configure an admin csr file: ./build/tls/admin-csr.json"
  [[ ! -f ./build/tls/etcd-csr.json ]] && die "please configure an etcd client csr file: ./build/tls/etcd-csr.json"

  [[ ! -f ./build/tls/${environment}/ca-key.pem ]] && genCA
  [[ ! -f ./build/tls/${environment}/admin-key.pem ]] && genAdmin
  [[ ! -f ./build/tls/${environment}/etcd-key.pem ]] && genEtcd
  [[ ! -f ./build/tls/${environment}/sa.pem ]] && genServiceAccount

}


#shift
# getopts
while :; do
  case $1 in
    -h|-\?|--help)
      usage    # Display a usage synopsis.
      exit
      ;;
    -e|--env*)
      if [ "$2" ]; then
        environment=$2
        shift
      else
        die 'ERROR: "--environment" requires a non-empty option argument.'
      fi
    ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *)
      break
      ;;
  esac
  shift
done

main
