"resource" "null_resource" "cluster-kubeconfig" {
  "depends_on" = ["null_resource.cluster-masters"]
  "provisioner" "local-exec" {
    "command" = "echo '${data.template_file.kubeconfig.rendered}' > config-${var.k8s_cluster_name}-${var.k8s_cluster_environment}"
  }
}