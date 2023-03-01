# resource "kubernetes_manifest" "argo_project" {
#   depends_on = [
#     helm_release.argocd
#   ]

#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "AppProject"
#     metadata = {
#       name = "store"
#       namespace = "argocd"
#     }
#     spec = {
#       clusterResourceWhitelist = [
#         {
#           group = "*"
#           kind  = "*"
#         }
#       ]
#       destination = [
#         {
#           namespace = "*"
#           namespace = "*"
#           server    = "https://kubernetes.default.svc"
#         }
#       ]
#       sourceRepos = [
#         "*"
#       ]
#     }
#   }
# }
