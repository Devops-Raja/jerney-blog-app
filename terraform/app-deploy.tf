#deploying app into k8 once argo cd is up
resource "kubernetes_namespace" "jerney" {
  metadata {
    name = "jerney"
  }
}

resource "kubernetes_manifest" "jerney_app_definition" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "jerney-blog-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/YOUR_USERNAME/jerney-blog-app.git" # MUST BE YOUR REPO
        targetRevision = "main"
        path           = "k8s" # This folder must exist in your repo
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "jerney"
      }
      syncPolicy = {
        automated = {
          selfHeal = true
          prune    = true
        }
      }
    }
  }

  # This ensures the namespace and ArgoCD exist before trying to create the app
  depends_on = [helm_release.argocd, kubernetes_namespace.jerney]
}