.PHONY: up down status urls load

up:
	cd terraform && terraform init -input=false && terraform apply -auto-approve

down:
	cd terraform && terraform destroy -auto-approve

status:
	kubectl get nodes
	kubectl get pods -A

urls:
	@echo "tasks-api:  http://tasks-api.local/tasks   (add '127.0.0.1 tasks-api.local' to /etc/hosts, or use --resolve)"
	@echo "grafana:    kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
	@echo "prometheus: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"

load:
	@echo "generating load against tasks-api for 60s (watch the HPA with: kubectl get hpa -n tasks-api -w)"
	@for i in $$(seq 1 60); do \
		for j in 1 2 3 4; do curl -s -o /dev/null --resolve tasks-api.local:80:127.0.0.1 http://tasks-api.local/tasks & done; \
		wait; \
		sleep 1; \
	done
