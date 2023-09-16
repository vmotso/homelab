locals {
  namespace = "cert-manager"
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  timeout    = 120
  namespace  = local.namespace
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.11.0"
  values     = ["${file("${path.module}/values.yaml")}"]

  wait = true
  lint = true

}

resource "kubernetes_manifest" "cluster_issuer_letsencrypt-prod" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-prod"
    }
    "spec" = {
      "acme" = {
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod-issuer-key"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [{
          "dns01" = {
            "cloudflare" = {
              "apiTokenSecretRef" = {
                "name" = "cloudflare-api-token"
                "key"  = "api-token"
              }
            }
          }
        }]
      }
    }
  }
  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
  depends_on = [
    helm_release.cert_manager
  ]
}
