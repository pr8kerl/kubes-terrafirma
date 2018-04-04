"resource" "vsphere_virtual_machine" "kubevm" {
  "count" = "${var.k8s_node_count}"
  "datacenter" = "${var.vsphere_datacenter}"
  "disk" = {
    "bootable" = true
    "datastore" = "${var.vsphere_datastore}"
    "template" = "${var.vsphere_template}"
    "type" = "thin"
  }
  "dns_servers" = ["10.60.4.83", "10.60.4.84"]
  "dns_suffixes" = ["cluster.local", "myob.myobcorp.net"]
  "enable_disk_uuid" = true
  "folder" = "${vsphere_folder.cluster_folder.path}"
  "memory" = 4096
  "name" = "${var.k8s_cluster_name}-${var.k8s_cluster_environment}-node${count.index}"
  "network_interface" = {
    "ipv4_address" = "${element(var.k8s_node_ips, count.index)}"
    "ipv4_gateway" = "${var.k8s_public_network_gateway}"
    "ipv4_prefix_length" = "${var.k8s_public_network_cidr_prefix}"
    "label" = "${var.vsphere_vlan}"
  }
  "resource_pool" = "${var.vsphere_resourcepool}"
  "vcpu" = 2
}