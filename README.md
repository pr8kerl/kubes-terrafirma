# kubes-terrafirma

## vsphere + terraform + kubeadm == kubes-terrafirma

A project to assist in provisioning kubernetes on vsphere.

It uses terraform and kubeadm.

## How?

* install docker and docker-compose locally

* build an esx template vm with docker, kubeadm, kubectl and kubelet installed. See [vm-base](vm-base.md) for CentOS 7 setup notes.

* generate a kubeadm bootstrap token for nodes

  ```
  make token
  ```
  save the resulting token for the `k8s_bootstrap_token` input variable

* update terraform input variables 

  ```
  cp build/global.tfvars.example build/global.tfvars
  cp build/environment.tfvars.example build/<environment name>.tfvars
  vi build/global.tfvars  build/<environment name>.tfvars
  ```

* generate ca cert and cluster admin cert

  ```
  make ca-<environment name> clustername=<cluster name that matches terraform variable k8s_cluster_name>
  ```

* set some sensitive info as environment variables for terraform to pickup

  ```
  TF_VAR_k8s_root_password="SuperSecretSquirrelRootPassword"
  TF_VAR_vsphere_password="SuperSecretSquirrelVspherePassword"

  export TF_VAR_k8s_root_password TF_VAR_vsphere_password
  ```

* see if the terraform gods are smiling

  ```
  make plan-<environment name>
  ```

* build a k8s cluster

  ```
  make apply-<environment name>
  ```

* destroy a k8s cluster

  ```
  make destroy-<environment name>
  ```

## Load Balancer??

You will probably want a load balancer to manage traffic to your ingress controller for your apps.
Or if your ingress controller is a daemonset and uses a NodePort service using ports 80 and 443, then you can probably get away with round robin dns pointing to all your nodes.

If you have an f5, you can use [f5er](https://github.com/pr8kerl/f5er) to create the required F5 resources.

* Copy the file **f5/example-environment.json** to **<envirnment>.json** and adjeust the settings.

* Configure your F5 credentials in a config file

  ```
  mkdir ~/.f5
  cat <<EOF > ~/.f5/f5.bla 
  {
  "device": "192.168.1.100",
  "username": "admin",
  "passwd": "letmeinplease"
  }
  EOF
  ```

* create your F5 load balancer stack

  ```
  make f5er-add-<environment>
  ```
