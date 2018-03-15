"resource" "null_resource" "cluster-node" {

  "count" = "${var.k8s_node_count}"

  "connection" = {
    "host" = "${element(var.k8s_node_ips, count.index)}"
    "user" = "root"
    "password" = "${var.k8s_root_password}"
  }

  "depends_on" = ["vsphere_virtual_machine.kubevm"]

  "provisioner" "remote-exec" {
    "inline" = [
			"hostnamectl set-hostname ${var.k8s_cluster_name}-${var.k8s_cluster_environment}-node${count.index +1}"
    ]
  }

  "provisioner" "file" {
    "content" = "${data.template_file.cloudprovider.rendered}"
    "destination" = "/etc/vsphere/config"
  }

  "provisioner" "file" {
    "content" = "${data.template_file.provision_node.rendered}"
    "destination" = "/etc/kubernetes/provision.sh"
  }

  "provisioner" "remote-exec" {
    "inline" = [
			"bash /etc/kubernetes/provision.sh ${var.k8s_cluster_name}-${var.k8s_cluster_environment}-node${count.index + 1}"
		]
  }

}