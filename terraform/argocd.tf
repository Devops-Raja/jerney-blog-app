resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.0.0"

  # Expose UI via LoadBalancer so you can access it
  values = [
    <<EOF
server:
  service:
    type: ClusterIP
  extraArgs:
    - --rootpath=/argocd
    - --insecure
configs:
  params:
    server.insecure: true
EOF
  ]

  depends_on = [helm_release.aws_load_balancer_controller]
}