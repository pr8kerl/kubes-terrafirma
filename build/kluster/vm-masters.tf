"resource" "vsphere_virtual_machine" "kubemastervm" {
  "count" = "${var.k8s_master_count}"
  "datacenter" = "${var.vsphere_datacenter}"

  "disk" = {
    "bootable" = true
    "datastore" = "${var.vsphere_datastore}"
    "template" = "${var.vsphere_template}"
    "type" = "thin"
  }

  "dns_servers" = "${var.k8s_public_network_dns_servers}"
  "dns_suffixes" = ["cluster.local", "myob.myobcorp.net"]
  "enable_disk_uuid" = true
  "folder" = "${vsphere_folder.cluster_folder.path}"
  "memory" = 4096
  "name" = "${var.k8s_cluster_name}-${var.k8s_cluster_environment}-master${count.index}"
  "network_interface" = {
    "ipv4_address" = "${element(var.k8s_master_ips, count.index)}"
    "ipv4_gateway" = "${var.k8s_public_network_gateway}"
    "ipv4_prefix_length" = "${var.k8s_public_network_cidr_prefix}"
    "label" = "${var.vsphere_vlan}"
  }

  "resource_pool" = "${var.vsphere_resourcepool}"
  "vcpu" = 2
}