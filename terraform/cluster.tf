provider "kind" {}

resource "kind_cluster" "this" {
  name           = "tasks-api"
  wait_for_ready = true
}

provider "kubernetes" {
  host                   = kind_cluster.this.endpoint
  client_certificate     = kind_cluster.this.client_certificate
  client_key             = kind_cluster.this.client_key
  cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = "tasks-api"
  }

  depends_on = [kind_cluster.this]
}
