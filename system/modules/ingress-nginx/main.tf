locals {
  namespace = "ingress-nginx"
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx/ingress-nginx"

  timeout         = 120
  cleanup_on_fail = true
  namespace       = local.namespace
  version         = "4.6.0"

  depends_on = [
    kubernetes_namespace.ingress_nginx
  ]
}
