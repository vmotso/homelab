terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    zerotier = {
      source  = "zerotier/zerotier"
      version = "~> 1.4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

locals {
  k8s_config_path = "./metal/kubeconfig.yaml"
}

provider "helm" {
  kubernetes {
    config_path = local.k8s_config_path
  }
}

provider "kubernetes" {
  config_path    = local.k8s_config_path
  config_context = "default"
}
provider "kubectl" {
  config_path = local.k8s_config_path
}

provider "cloudflare" {
  api_key = var.cloudflare_api_key
  email   = var.cloudflare_email
}

provider "zerotier" {
  zerotier_central_token = var.zerotier_central_token
  zerotier_central_url   = "https://my.zerotier.com/api"
}
