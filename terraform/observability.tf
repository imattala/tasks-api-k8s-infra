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
      prometheusOperator = {
        # Its cert-gen pre-install hook (same pattern as ingress-nginx's
        # admission webhook) only guards PrometheusRule validation, which
        # this project doesn't use - and it proved flaky on a single-node
        # kind cluster (first apply timed out waiting on that hook's Job).
        # Dropping it removes that failure mode instead of just retrying.
        admissionWebhooks = {
          enabled = false
        }
        # tls.enabled is a separate flag from admissionWebhooks - it's what
        # makes the operator itself mount a TLS secret that only the
        # disabled cert-gen job would have created, so it has to go too.
        tls = {
          enabled = false
        }
      }
    })
  ]

  depends_on = [kind_cluster.this]
}
