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
  ]

  # ingress-nginx and metrics-server both need to be up before the HPA
  # can actually do anything useful.
  depends_on = [
    terraform_data.load_app_image,
    helm_release.ingress_nginx,
    helm_release.metrics_server,
  ]
}
