# kube-prometheus-stack bundles the Prometheus Operator, Prometheus,
# Grafana, Alertmanager, node-exporter, and kube-state-metrics - the
# standard way to get Prometheus+Grafana onto a real cluster (not just a
# bare prometheus+grafana chart pair).
resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "92.14.0"
  namespace        = "monitoring"
  create_namespace = true
  timeout          = 300

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          # Default selector only watches ServiceMonitors carrying this
          # release's own `release` label - simpler to just watch everything
          # in a single-tenant local dev cluster than keep that label in sync.
          serviceMonitorSelectorNilUsesHelmValues = false
        }
      }
      grafana = {
        adminPassword = "admin"
      }
    })
  ]

  depends_on = [kind_cluster.this]
}
