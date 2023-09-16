locals {
  namespace   = "argocd"
  values_yaml = templatefile("${path.module}/values.yaml.tpl", { repo_token = var.homelab_repo_token })
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  timeout         = 120
  cleanup_on_fail = true
  namespace       = local.namespace
  version         = "5.46.0"
  values          = ["${local.values_yaml}"]
}
