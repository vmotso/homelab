locals {
  namespace      = "prometheus-stack"
  admin_password = "admin"
}

resource "kubernetes_namespace" "prometheus_stack" {
  metadata {
    name = local.namespace
  }
}
resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  timeout         = 120
  cleanup_on_fail = true
  namespace       = local.namespace
  version         = "45.10.1"
  values          = ["${file("${path.module}/values.yaml")}"]

  set {
    name  = "grafana.adminPassword"
    value = local.admin_password
  }

  depends_on = [
    kubernetes_namespace.prometheus_stack
  ]
}

output "grafana_creds" {
  value = "${local.admin_password}/${local.admin_password}"
}
