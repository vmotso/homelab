module "metallb" {
  source = "./modules/metallb"

  addresses = var.metallb_addresses
}

module "ingress_nginx" {
  source = "./modules/ingress-nginx"

  depends_on = [
    module.metallb
  ]
}

module "prometheus_stack" {
  source = "./modules/prometheus-stack"

  depends_on = [
    module.metallb
  ]
}

module "external_dns" {
  source = "./modules/external-dns"

  depends_on = [
    module.metallb
  ]
}

module "cert_manager" {
  source = "./modules/cert-manager"

  depends_on = [
    module.ingress_nginx,
    module.prometheus_stack
  ]
}

module "cloudflared" {
  source = "./modules/cloudflared"
  depends_on = [
    module.ingress_nginx
  ]
}

module "zerotier_router" {
  source = "./modules/zerotier-router"

  depends_on = [
    module.ingress_nginx
  ]
}


module "longhorn" {
  source = "./modules/longhorn"

  depends_on = [
    module.ingress_nginx,
    module.prometheus_stack
  ]
}


output "grafana_creds" {

  value = module.prometheus_stack.grafana_creds
  
}