variable "vsphere_unverified_ssl" {
  type    = "string"
  default = "true"
}

variable "vsphere_domain" {
  type        = "string"
  description = "vsphere active directory auth domain"
}

variable "vsphere_user" {
  type        = "string"
  description = "vsphere user name"
}

variable "vsphere_password" {
  type        = "string"
  description = "password for vsphere user"
}

variable "vsphere_server" {
  type        = "string"
  description = "vsphere server name or ip address"
}

variable "vsphere_port" {
  description = "vsphere server port"
  default = 443
}

variable "vsphere_cluster" {
  type        = "string"
  description = "vsphere cluster to locate k8s"
}

variable "vsphere_datacenter" {
  type        = "string"
  description = "vsphere datacenter to locate k8s"
}

variable "vsphere_datastore" {
  type        = "string"
  description = "vsphere datastore to locate vm storage"
}

variable "vsphere_resourcepool" {
  type        = "string"
  description = "vsphere resource pool location"
}


variable "vsphere_template" {
  type        = "string"
  description = "vmware template to provision k8s vms"
}

variable "vsphere_vlan" {
  type        = "string"
  description = "vsphere network name to provision cluster on"
}

variable "vsphere_folderpath" {
  type        = "string"
  description = "vsphere folder path to locate vms"
}

variable "etcd_version" {
  type        = "string"
  description = "version of etcd to use"
  default = "v3.1.10"
}

variable "k8s_version" {
  type        = "string"
  description = "version of kubernetes hyperkube to use"
  default = "v1.9.2"
}

variable "k8s_version_major" {
  type        = "string"
  description = "major version of kubernetes hyperkube to use"
  default = "1.8"
}

variable "k8s_cluster_name" {
  type        = "string"
  description = "name of the k8s cluster"
}

variable "k8s_cluster_environment" {
  type        = "string"
  description = "name of the k8s cluster environment"
}

variable "k8s_master_lb_ip" {
  type        = "string"
  description = "k8s api load balancer virtual ip address"
}

variable "k8s_master_lb_hostname" {
	type        = "string"
	description = "k8s api load balancer fqdn"
}

variable "k8s_master_count" {
  description = "number of k8s masters to provision"
  default = 3
}

variable "k8s_master_ips" {
  type        = "list"
  description = "ip addresses of k8s masters"
}

variable "k8s_node_count" {
  description = "number of k8s nodes to provision"
  default = 3
}

variable "k8s_node_ips" {
  type        = "list"
  description = "ip addresses of k8s nodes"
}

variable "k8s_public_network_dns_servers" {
  type        = "list"
  description = "ip addresses of dns servers used on k8s nodes"
}

variable "k8s_public_network_gateway" {
  type        = "string"
  description = "ip address of k8s network gateway"
}

variable "k8s_public_network_cidr_prefix" {
  type        = "string"
  default = "24"
  description = "subnet cidr prefix for k8s network"
}

variable "k8s_bootstrap_token" {
  type        = "string"
  description = "token to allow nodes to join"
}

variable "k8s_service_cidr" {
  type        = "string"
  description = "k8s internal service network"
}

variable "k8s_podnetwork_cidr" {
  type        = "string"
  description = "k8s internal pod network"
  default = "10.244.0.0/16"
}

variable "k8s_podnetwork" {
  type        = "string"
  description = "k8s cni pod network flavour"
  default = "flannel"
}

variable "k8s_root_password" {
  type        = "string"
  description = "root password access to nodes"
}

variable "k8s_kubeadm_config" {
  type        = "string"
  description = "k8s kubeadm init config file location"
  default = "/etc/kubernetes/kubeadm.yaml"
}

variable "k8s_oidc_issuer_url" {
  type        = "string"
  description = "k8s oidc authentication issuer url"
}

variable "k8s_oidc_client_id" {
  type        = "string"
  description = "k8s oidc client identifier"
}

variable "k8s_oidc_username_claim" {
  type        = "string"
  description = "k8s oidc username claim"
  default = "upn"
}

variable "k8s_oidc_groups_claim" {
  type        = "string"
  description = "k8s oidc groups claim"
  default = "group"
}

