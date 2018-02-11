"resource" "vsphere_folder" "cluster_folder" {
  "datacenter" = "${var.vsphere_datacenter}"

  "path" = "${var.vsphere_folderpath}/${var.k8s_cluster_environment}"
}