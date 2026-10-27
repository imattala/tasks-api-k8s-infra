# tasks-api-k8s-infra

![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-kind-326CE5?logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-charts-0F1689?logo=helm&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A deliberately simple CRUD API + Postgres, deployed entirely via Terraform
onto a local Kubernetes cluster (`kind`) — with Helm packaging, ingress,
autoscaling, and a Prometheus/Grafana monitoring stack. The app itself is
unglamorous on purpose: Terraform and Kubernetes operations are the actual
subject of this project.

Built as a portfolio project, one milestone at a time. See open issues/PRs
for progress.

## Architecture

```
Terraform
  ├─ kind provider       → creates the local Kubernetes cluster
  ├─ kubernetes provider → namespace
  └─ helm provider       → the tasks-api chart (charts/tasks-api);
                            later also ingress-nginx, kube-prometheus-stack

Inside the cluster:
  tasks-api (FastAPI + SQLAlchemy)  ──►  Postgres (PVC)
       │  /metrics
       ▼
  Prometheus + Grafana

  Ingress (ingress-nginx) routes external traffic to tasks-api
  HorizontalPodAutoscaler scales tasks-api on CPU load
```

## Status

Work in progress — see the [issues](../../issues) for the milestone breakdown.

- [x] M1 — Cluster via Terraform
- [x] M2 — App + database on Kubernetes
- [x] M3 — Helm chart
- [x] M4 — Ingress + autoscaling
- [x] M5 — Observability on Kubernetes
- [ ] M6 — Polish

## Running it

**Prerequisites:** Docker, Terraform, `kind`, `kubectl`, `helm` — see
[docs/prerequisites.md](docs/prerequisites.md) (all installed as plain
user-local binaries, no system package manager or `sudo` needed).

```
cd terraform
terraform init
terraform apply
```

Tear everything down with:

```
terraform destroy
```

## License

MIT
