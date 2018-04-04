"resource" "null_resource" "cluster-init" {
  "count" = "${var.k8s_master_count}"
  "connection" = {
    "host" = "${element(var.k8s_master_ips, count.index)}"
    "user" = "root"
    "password" = "${var.k8s_root_password}"
  }

  "depends_on" = ["null_resource.cluster-masters"]

  "provisioner" "file" {
    "content" = "${data.template_file.init_master.rendered}"
    "destination" = "/etc/kubernetes/init.sh"
  }

  "provisioner" "remote-exec" {
    "inline" = [
			"bash /etc/kubernetes/init.sh"
		]
  }
}