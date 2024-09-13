provider "helm" {
  kubernetes {
    config_path = "./../02-cluster/kubeconfig"
  }
}
