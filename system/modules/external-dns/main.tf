resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"

  timeout         = 120
  cleanup_on_fail = true
  namespace       = "external-dns"
  version         = "1.12.2"
  values          = ["${file("${path.module}/values.yaml")}"]
}