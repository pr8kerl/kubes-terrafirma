"resource" "null_resource" "cluster-master" {
  "count" = 1
  "connection" = {
    "host" = "${vsphere_virtual_machine.kubemastervm.0.network_interface.0.ipv4_address}"
    "user" = "root"
    "password" = "${var.k8s_root_password}"
  }

  "depends_on" = ["vsphere_virtual_machine.kubemastervm"]

  "provisioner" "remote-exec" {
    "inline" = [
			"hostnamectl set-hostname ${var.k8s_cluster_name}-${var.k8s_cluster_environment}-master${count.index +1}"
    ]
  }

  "provisioner" "file" {
    "source" = "tls/${var.k8s_cluster_environment}/ca.pem"
    "destination" = "/etc/kubernetes/pki/ca.crt"
  }

  "provisioner" "file" {
    "source" = "tls/${var.k8s_cluster_environment}/ca-key.pem"
    "destination" = "/etc/kubernetes/pki/ca.key"
  }

  "provisioner" "file" {
    "source" = "tls/${var.k8s_cluster_environment}/ca.pem"
    "destination" = "/etc/kubernetes/pki/front-proxy-ca.crt"
  }

  "provisioner" "file" {
    "source" = "tls/${var.k8s_cluster_environment}/ca-key.pem"
    "destination" = "/etc/kubernetes/pki/front-proxy-ca.key"
  }

  "provisioner" "file" {
    "content" = "${data.template_file.cloudprovider.rendered}"
    "destination" = "/etc/kubernetes/vsphere.conf"
  }

  "provisioner" "file" {
    "content" = "${data.template_file.provision_master.rendered}"
    "destination" = "/etc/kubernetes/provision.sh"
  }

  "provisioner" "file" {
    "content" = "${data.template_file.kubeadmcfg.rendered}"
    "destination" = "/etc/kubernetes/kubeadm.yaml"
  }

  "provisioner" "remote-exec" {
    "inline" = [
			"bash /etc/kubernetes/provision.sh"
		]
  }
}