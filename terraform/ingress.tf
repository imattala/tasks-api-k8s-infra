# ingress-nginx, configured to match kind's own recipe for it: hostPort
# instead of a cloud LoadBalancer (kind has none), tolerating the
# control-plane taint since our single-node cluster has nowhere else to
# schedule it.
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.15.1"
  namespace        = "ingress-nginx"
  create_namespace = true

  set = [
    {
      name  = "controller.hostPort.enabled"
      value = "true"
    },
    {
      name  = "controller.service.type"
      value = "ClusterIP" # hostPort handles external access; no cloud LB to assign
    },
  ]

  values = [
    yamlencode({
      controller = {
        tolerations = [
          {
            key      = "node-role.kubernetes.io/control-plane"
            operator = "Equal"
            effect   = "NoSchedule"
          }
        ]
      }
    })
  ]

  depends_on = [kind_cluster.this]
}
