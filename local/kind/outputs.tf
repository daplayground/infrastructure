output "helm_release_argocd_manifest" {
  value = helm_release.argocd.manifest
}

output "helm_release_argocd_metadata" {
  value = helm_release.argocd.metadata
}

# output "helm_release_argocd_notes" {
#   value = data.helm_template.argocd.notes
# }
