resource "helm_release" "tasks_api" {
  name      = "tasks-api"
  namespace = kubernetes_namespace_v1.app.metadata[0].name
  chart     = "${path.module}/../charts/tasks-api"

  set = [
    {
      name  = "api.image.repository"
      value = split(":", local.app_image)[0]
    },
    {
      name  = "api.image.tag"
      value = split(":", local.app_image)[1]
    },
    {
      name  = "api.replicaCount"
      value = "1"
    },
  ]

  depends_on = [terraform_data.load_app_image]
}
