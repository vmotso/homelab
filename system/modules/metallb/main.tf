locals {
  namespace = "metallb"
}

resource "kubernetes_namespace" "metallb" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"

  timeout         = 120
  cleanup_on_fail = true
  namespace       = local.namespace
  version         = "0.13.9"

  depends_on = [
    kubernetes_namespace.metallb
  ]
}

resource "kubernetes_manifest" "ip_address_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"

    metadata = {
      name      = "main-pool"
      namespace = local.namespace
    }

    spec = {
      addresses = var.addresses
    }
  }
  depends_on = [
    helm_release.metallb
  ]
}

resource "kubernetes_manifest" "l2_advertisement" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"

    metadata = {
      name      = "l2"
      namespace = local.namespace
    }
    spec = {
      ipAddressPools = ["main-pool"]
    }
  }

  depends_on = [
    kubernetes_manifest.ip_address_pool
  ]
}
