terraform {
  required_providers {
    zerotier = {
      source  = "zerotier/zerotier"
      version = "~> 1.4.0"
    }
  }
}

locals {
  managed_route = "192.168.168.0/24"
  router_ip     = cidrhost(local.managed_route, 1) # Use the second IP in the VPN subnet as the router
  namespace     = "zerotier"
}

resource "zerotier_network" "network" {
  name        = "homelab"
  description = "Homelab network"
  private     = true

  route {
    target = local.managed_route
  }

  route {
    target = var.bridged_route
    via    = local.router_ip
  }

  assignment_pool {
    start = cidrhost(local.managed_route, 0)
    end   = cidrhost(local.managed_route, -1)
  }
}

resource "zerotier_identity" "router" {}

resource "zerotier_member" "router" {
  network_id              = zerotier_network.network.id
  name                    = "router"
  member_id               = zerotier_identity.router.id
  allow_ethernet_bridging = true
  no_auto_assign_ips      = true
  ip_assignments = [
    local.router_ip
  ]
}

resource "kubernetes_namespace" "zerotier" {
  metadata {
    name = local.namespace
  }
  depends_on = [
    zerotier_member.router
  ]
}

resource "kubernetes_secret" "router" {
  metadata {
    name      = "zerotier-router"
    namespace = kubernetes_namespace.zerotier.metadata[0].name
  }

  data = {
    ZEROTIER_NETWORK_ID      = zerotier_network.network.id
    ZEROTIER_IDENTITY_PUBLIC = zerotier_identity.router.public_key
    ZEROTIER_IDENTITY_SECRET = zerotier_identity.router.private_key
  }
}
