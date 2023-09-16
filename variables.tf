# External
# --------
variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API Key"
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Cloudflare Account email"
  type        = string
}

variable "cloudflare_zone" {
  description = "Cloudflare Zone"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "zerotier_central_token" {
  description = "ZeroTier Central API Token"
  type        = string
  sensitive   = true
}

variable "zerotier_bridged_route" {
  description = "Bridged route(Internal LAN)"
  type        = string
  default     = "192.168.42.0/24"
}
# System
# ------
variable "metallb_addresses" {
  type        = list(string)
  description = "MetalLB IP Address Pool"
  default     = ["192.168.42.230-192.168.42.250"]
}

# Bootstrap
# ---------

variable "homelab_repo_url" {
  type        = string
  description = "Homelab repo URL"
}

variable "homelab_repo_token" {
  type        = string
  description = "GitHub Access Token with repo skope"
  sensitive   = true
}
