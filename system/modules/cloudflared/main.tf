resource "helm_release" "cloudflared" {
  name       = "cloudflared"
  repository = "https://vmotso.github.io/helm-charts"
  chart      = "cloudflared"

  timeout         = 120
  cleanup_on_fail = true
  namespace       = "cloudflared"
  version         = "1.0.0"
  values          = ["${file("${path.module}/values.yaml")}"]
}
