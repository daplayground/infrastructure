resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.22.1"
  create_namespace = true
  force_update     = true

  # values = [
  #   file("../argocd/root.yaml")
  # ]
}

resource "helm_release" "argocd_apps" {
  depends_on       = [helm_release.argocd]
  name             = "argocd-apps"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-apps"
  namespace        = "argocd"
  version          = "0.0.8"
  create_namespace = true
  force_update     = true

  values = [
    file("../../argocd/root.yaml")
  ]
}
