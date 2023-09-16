terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "external_dns" {
  name = "homelab_external_dns"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["Zone Read"],
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"]
    ]
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
  }

  condition {
    request_ip {
      not_in = ["198.160.42.111/32"] # stub: I have not static IP yet.
    }
  }
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
  depends_on = [
    cloudflare_api_token.external_dns
  ]
}

resource "kubernetes_secret" "external_dns_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "external-dns"
  }

  data = {
    value = cloudflare_api_token.external_dns.value
  }

  depends_on = [
    kubernetes_namespace.external_dns
  ]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "cert-manager"
  }

  data = {
    api-token = cloudflare_api_token.external_dns.value
  }

  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

# Tunnel

data "cloudflare_zone" "zone" {
  name = var.zone
}

resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

locals {
  tunnel_secret = base64encode(random_password.tunnel_secret.result)
  tunnel_name   = "homelab"
}

resource "cloudflare_argo_tunnel" "homelab" {
  account_id = var.account_id
  name       = local.tunnel_name
  secret     = local.tunnel_secret
}

# Not proxied, not accessible. Just a record for auto-created CNAMEs by external-dns.
resource "cloudflare_record" "tunnel" {
  zone_id = data.cloudflare_zone.zone.id
  type    = "CNAME"
  name    = "homelab-tunnel"
  value   = "${cloudflare_argo_tunnel.homelab.id}.cfargotunnel.com"
  proxied = false
  ttl     = 1
}

resource "kubernetes_namespace" "cloudflared" {
  metadata {
    name = "cloudflared"
  }

  depends_on = [
    cloudflare_argo_tunnel.homelab
  ]
}

resource "kubernetes_secret" "cloudflared_credentials" {
  metadata {
    name      = "cloudflared-credentials"
    namespace = "cloudflared"
  }

  data = {
    "credentials.json" = jsonencode({
      AccountTag   = var.account_id
      TunnelName   = local.tunnel_name
      TunnelID     = cloudflare_argo_tunnel.homelab.id
      TunnelSecret = local.tunnel_secret
    })
  }

  depends_on = [
    kubernetes_namespace.cloudflared
  ]
}
