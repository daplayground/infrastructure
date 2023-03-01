
provider "kind" {}

provider "kubernetes" {
  config_path    = "./store-config"
  config_context = "kind-daplayground"
}

provider "kubectl" {
  host                   = kind_cluster.daplayground.endpoint
  cluster_ca_certificate = kind_cluster.daplayground.cluster_ca_certificate
  client_certificate     = kind_cluster.daplayground.client_certificate
  client_key             = kind_cluster.daplayground.client_key
}

provider "helm" {
  kubernetes {
    host                   = kind_cluster.daplayground.endpoint
    cluster_ca_certificate = kind_cluster.daplayground.cluster_ca_certificate
    client_certificate     = kind_cluster.daplayground.client_certificate
    client_key             = kind_cluster.daplayground.client_key
  }
}
