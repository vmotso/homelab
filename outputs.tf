output "cloudflare_tunnel_id" {
  value = module.external.cloudflare_tunnel_id
}

output "zerotier_network_id" {
  value = module.external.zerotier_network_id
}

output "grafana_creds" {
  value = module.system.grafana_creds
}
