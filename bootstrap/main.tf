module "argocd" {
  source             = "./modules/argocd"
  homelab_repo_token = var.homelab_repo_token
}

module "root" {
  source           = "./modules/root"
  homelab_repo_url = var.homelab_repo_url
}