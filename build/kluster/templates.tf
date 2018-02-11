data "template_file" "cloudprovider" {
  template = "${file("./templates/vsphere.conf")}"
  vars = {
    "allow_unverified_ssl" = "${var.vsphere_unverified_ssl}"
    "datacenter" = "${var.vsphere_datacenter}"
    "datastore" = "${var.vsphere_datastore}"
    "password" = "${var.vsphere_password}"
    "port" = "${var.vsphere_port}"
    "username" = "${var.vsphere_domain}\\\\${var.vsphere_user}"
    "vsphere_server" = "${var.vsphere_server}"
    "working_dir" = "kubernetes/${var.k8s_cluster_name}-${var.k8s_cluster_environment}"
  }
}

data "template_file" "provision_master" {
  template = "${file("./templates/provision-master.sh")}"
  vars = {
    "k8s_service_cidr" = "${var.k8s_service_cidr}"
    "k8s_podnetwork" = "${var.k8s_podnetwork}"
    "k8s_bootstrap_token" = "${var.k8s_bootstrap_token}"
    "k8s_kubeadm_config" = "${var.k8s_kubeadm_config}"
  }
}

data "template_file" "provision_node" {
  template = "${file("./templates/provision-node.sh")}"
  vars = {
    "k8s_master_ip" = "${var.k8s_master_ips[0]}"
    "k8s_service_cidr" = "${var.k8s_service_cidr}"
    "k8s_bootstrap_token" = "${var.k8s_bootstrap_token}"
  }
}

data "template_file" "kubeadmcfg" {
  template = "${file("./templates/kubeadm.yaml")}"
  vars = {
    "k8s_version" = "${var.k8s_version}"
    "k8s_master_ip" = "${var.k8s_master_ips[0]}"
    "k8s_service_cidr" = "${var.k8s_service_cidr}"
    "k8s_podnetwork_cidr" = "${var.k8s_podnetwork_cidr}"
    "k8s_bootstrap_token" = "${var.k8s_bootstrap_token}"
    "k8s_cluster_name" = "${var.k8s_cluster_name}"
    "k8s_cluster_environment" = "${var.k8s_cluster_environment}"
    "k8s_oidc_issuer_url" = "${var.k8s_oidc_issuer_url}"
    "k8s_oidc_client_id" = "${var.k8s_oidc_client_id}"
    "k8s_oidc_username_claim" = "${var.k8s_oidc_username_claim}"
    "k8s_oidc_groups_claim" = "${var.k8s_oidc_groups_claim}"
  }
}

"data" "template_file" "kubeconfig" {
  "template" = "${file("./templates/kubeconfig.json")}"
  "vars" = {
    "k8s_cluster_name" = "${var.k8s_cluster_name}"
    "k8s_cluster_environment" = "${var.k8s_cluster_environment}"
    "k8s_master_ip" = "${var.k8s_master_ips[0]}"
    "root_pem" = "${base64encode(data.template_file.ca_pem.rendered)}"
    "admin_pem" = "${base64encode(data.template_file.admin_pem.rendered)}"
    "admin_key" = "${base64encode(data.template_file.adminkey_pem.rendered)}"
  }
}

"data" "template_file" "ca_pem" {
  "template" = "${file("./tls/${var.k8s_cluster_environment}/ca.pem")}"
}

"data" "template_file" "admin_pem" {
  "template" = "${file("./tls/${var.k8s_cluster_environment}/admin.pem")}"
}

"data" "template_file" "adminkey_pem" {
  "template" = "${file("./tls/${var.k8s_cluster_environment}/admin-key.pem")}"
}