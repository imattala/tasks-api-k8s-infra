resource "kubernetes_deployment_v1" "tasks_api" {
  metadata {
    name      = "tasks-api"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels    = { app = "tasks-api" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "tasks-api" }
    }

    template {
      metadata {
        labels = { app = "tasks-api" }
      }

      spec {
        enable_service_links = false # same reason as postgres.tf

        container {
          name              = "tasks-api"
          image             = local.app_image
          image_pull_policy = "Never" # loaded straight into the kind nodes, no registry

          env {
            name  = "POSTGRES_HOST"
            value = kubernetes_service_v1.postgres.metadata[0].name
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.postgres.metadata[0].name
            }
          }

          port {
            container_port = 8000
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
        }
      }
    }
  }

  depends_on = [terraform_data.load_app_image, kubernetes_deployment_v1.postgres]
}

resource "kubernetes_service_v1" "tasks_api" {
  metadata {
    name      = "tasks-api"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    selector = { app = "tasks-api" }

    port {
      port        = 80
      target_port = 8000
    }
  }
}
