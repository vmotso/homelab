module "external" {
  source                 = "./external"
  cloudflare_zone        = var.cloudflare_zone
  cloudflare_account_id  = var.cloudflare_account_id
  zerotier_bridged_route = var.zerotier_bridged_route
}

module "system" {
  source = "./system"
  depends_on = [
    module.external
  ]
  metallb_addresses = var.metallb_addresses
}

module "bootstrap" {
  source = "./bootstrap"

  homelab_repo_url   = var.homelab_repo_url
  homelab_repo_token = var.homelab_repo_token

  depends_on = [
    module.system
  ]
}
