locals {
  namespace = "longhorn"
}

resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"

  timeout         = 120
  cleanup_on_fail = true
  namespace       = local.namespace
  version         = "1.4.1"
  values          = ["${file("${path.module}/values.yaml")}"]
  depends_on = [
    kubernetes_namespace.longhorn
  ]
}

resource "kubernetes_manifest" "service_monitor" {
  manifest = yamldecode(file("${path.module}/service-monitor.yaml"))

  depends_on = [
    helm_release.longhorn
  ]
}


# data "local_file" "service_monitor_manifest" {
#   filename = file("${path.module}/service-monitor.yaml")
# }

# resource "kubernetes_manifest" "service_monitor" {
#   yaml_body         = data.local_file.service_monitor_manifest.content
#   server_side_apply = true

#   depends_on = [
#     helm_release.longhorn
#   ]
# }
