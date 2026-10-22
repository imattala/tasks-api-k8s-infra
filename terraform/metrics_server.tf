# HPA needs the metrics.k8s.io API, which only metrics-server provides -
# it isn't bundled in kind by default. kind's kubelet certs aren't valid
# for metrics-server's default strict TLS verification, hence the
# --kubelet-insecure-tls flag (fine for a local dev cluster).
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.14.0"
  namespace  = "kube-system"

  values = [
    yamlencode({
      args = ["--kubelet-insecure-tls"]
    })
  ]

  depends_on = [kind_cluster.this]
}
