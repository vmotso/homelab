server:
  extraArgs:
    - --insecure
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - &host argocd.vmotso.cloud
    tls:
      - secretName: argocd-tls-certificate
        hosts:
          - *host
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
      additionalLabels: {}

configs:
  repositories:
    - name: homelab
      url: https://github.com/vmotso/homelab
      username: oauth
      password: ${repo_token}
