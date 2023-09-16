resource "null_resource" "helm_template" {
  provisioner "local-exec" {
    command     = "helm template --include-crds --namespace argocd --values values.yaml --set=gitops.repo=${var.homelab_repo_url} argo . > manifest.yaml"
    working_dir = "${path.module}/chart"
  }
}

data "local_file" "manifest_yaml" {
  filename = "${path.module}/chart/manifest.yaml"
  depends_on = [
    null_resource.helm_template
  ]
}

resource "kubectl_manifest" "root" {
  yaml_body         = data.local_file.manifest_yaml.content
  server_side_apply = true
}
