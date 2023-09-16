module "cloudflare" {
  source = "./modules/cloudflare"

  zone       = var.cloudflare_zone
  account_id = var.cloudflare_account_id
}

module "zerotier" {
  source = "./modules/zerotier"

  bridged_route = var.zerotier_bridged_route
}
