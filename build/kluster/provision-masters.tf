"resource" "null_resource" "cluster-masters" {

  "count" = "${var.k8s_master_count}"

  "connection" = {
    "host" = "${element(var.k8s_master_ips, count.index)}"
    "user" = "root"
    "password" = "${var.k8s_root_password}"
  }

  "depends_on" = ["vsphere_virtual_machine.kubemastervm"]

  "provisioner" "remote-exec" {
    "inline" = [
			"hostnamectl set-hostname ${var.k8s_cluster_name}-${var.k8s_cluster_environment}-master${count.index}"
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
    "source" = "tls/${var.k8s_cluster_environment}/sa-key.pem"
    "destination" = "/etc/kubernetes/pki/sa.key"
  }

  "provisioner" "file" {
    "source" = "tls/${var.k8s_cluster_environment}/sa.pem"
    "destination" = "/etc/kubernetes/pki/sa.pub"
  }

  "provisioner" "file" {
    "source" = "tls/ca-config.json"
    "destination" = "/etc/kubernetes/pki/ca-config.json"
  }

  "provisioner" "file" {
    "source" = "tls/oidc-ca.pem"
    "destination" = "/etc/kubernetes/pki/oidc-ca.pem"
  }

  "provisioner" "file" {
    "source" = "tls/${var.k8s_cluster_environment}/ca.pem"
    "destination" = "/etc/kubernetes/pki/etcd/ca.pem"
  }

  "provisioner" "file" {
    "source" = "tls/${var.k8s_cluster_environment}/etcd-key.pem"
    "destination" = "/etc/kubernetes/pki/etcd/client-key.pem"
  }

  "provisioner" "file" {
    "source" = "tls/${var.k8s_cluster_environment}/etcd.pem"
    "destination" = "/etc/kubernetes/pki/etcd/client.pem"
  }

  "provisioner" "file" {
    "source" = "tls/etcd-peer.json"
    "destination" = "/etc/kubernetes/pki/etcd/etcd-csr.json"
  }

  "provisioner" "file" {
    "content" = "${data.template_file.cloudprovider.rendered}"
    "destination" = "/etc/vsphere/config"
  }

  "provisioner" "file" {
    "content" = "${element(data.template_file.kubeadmcfg.*.rendered, count.index)}"
    "destination" = "/etc/kubernetes/kubeadm.yaml"
  }

  "provisioner" "file" {
    "content" = "${element(data.template_file.etcdservice.*.rendered, count.index)}"
    "destination" = "/etc/systemd/system/etcd.service"
  }

  "provisioner" "file" {
    "content" = "${data.template_file.provision_master.rendered}"
    "destination" = "/etc/kubernetes/provision.sh"
  }

  "provisioner" "remote-exec" {
    "inline" = [
			"bash /etc/kubernetes/provision.sh"
		]
  }
}