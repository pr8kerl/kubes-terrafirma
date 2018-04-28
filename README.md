# kubes-terrafirma

## vsphere + terraform + kubeadm == kubes-terrafirma

A project to assist in provisioning kubernetes on vsphere.

Now with multiple kubernetes masters - etcd included.

It uses terraform and kubeadm.

## How?

* install docker and docker-compose locally

* build an esx template vm with docker, kubeadm, kubectl and kubelet installed. See [vm-base](vm-base.md) for CentOS 7 setup notes.

* update terraform input variables 

  ```
  cp build/global.tfvars.example build/global.tfvars
  cp build/environment.tfvars.example build/<environment name>.tfvars
  vi build/global.tfvars  build/<environment name>.tfvars
  ```

* generate a kubeadm bootstrap token for nodes

  ```
  make token
  ```
  save the resulting token for the `k8s_bootstrap_token` input variable

* edit the csr input files found in **build/tls/** to match your environment

* generate ca cert and other common keys/certs

  ```
  make certs-<environment name>
  ```

* copy oidc-ca.pem to build/tls/oidc-ca.pem. As currently configured, kubeadm is expecting a CA file for the oidc provider.
  This is only needed if using a non-trusted CA on your oidc provider endpoint (ie if your oidc server is private and posssibly hosted on-premise).
  If not needed, remove the oidc-ca.pem step from **provision-masters.tf** as well as from kubeadm.yaml.

* set some sensitive info as environment variables for terraform to pickup

  ```
  TF_VAR_k8s_root_password="SuperSecretSquirrelRootPassword"
  TF_VAR_vsphere_password="SuperSecretSquirrelVspherePassword"

  export TF_VAR_k8s_root_password TF_VAR_vsphere_password
  ```

* see if the terraform gods are smiling

  ```
  make plan-<environment name> clustername=<insert pet cluster name here>
  ```

* build a k8s cluster

  ```
  make apply-<environment name> clustername=<insert pet cluster name here>
  ```

* destroy a k8s cluster

  ```
  make destroy-<environment name>
  ```

## What is where??

What are all these directories??

```
.
├── bin           # scripts used by make steps
├── build         # terraform variable and state files are here
│   ├── kluster   # terraform files
│   ├── templates # templates parsed by terraform and installed on nodes
│   └── tls       # cfssl csr and config files are here
│       ├── environment # all generated certs/keys for an environment are dropped in here
├── f5 # example f5er input files are here
├── Makefile
├── README.md
├── vm-base.md
└── yaml # all k8s yaml files for the **install-environment** make target
```


## Load Balancer??

You will probably want a load balancer to manage traffic to your ingress controller for your apps.

You will probably want a load balancer to manage traffic to your k8s api masters.

Or if your ingress controller is a daemonset and uses a NodePort service using ports 80 and 443, then you can probably get away with round robin dns pointing to all your nodes.

If you have an f5, you can use [f5er](https://github.com/pr8kerl/f5er) to create the required F5 resources.

* Copy the file **f5/example-environment-apps.json** to **<environment>.json** and adjust the settings.

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
