resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.0.0"
  namespace        = "argocd"
  create_namespace = true
  timeout = 300 # it will take some time to install all the components, so we set a longer timeout
  

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