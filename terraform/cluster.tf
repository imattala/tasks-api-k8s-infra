provider "kind" {}

resource "kind_cluster" "this" {
  name           = "tasks-api"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Maps the control-plane node's 80/443 to the real host, so
      # ingress-nginx's hostPort setup is reachable at localhost - there's
      # only one node (no separate workers), so this is also the only node
      # ingress-nginx can schedule onto.
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }
    }
  }
}

provider "kubernetes" {
  host                   = kind_cluster.this.endpoint
  client_certificate     = kind_cluster.this.client_certificate
  client_key             = kind_cluster.this.client_key
  cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
}

provider "helm" {
  kubernetes = {
    host                   = kind_cluster.this.endpoint
    client_certificate     = kind_cluster.this.client_certificate
    client_key             = kind_cluster.this.client_key
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
  }
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = "tasks-api"
  }

  depends_on = [kind_cluster.this]
}
