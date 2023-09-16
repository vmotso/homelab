resource "kubernetes_manifest" "deployment_zerotier-router" {
  manifest = yamldecode(file("${path.module}/deployment.yaml"))
}