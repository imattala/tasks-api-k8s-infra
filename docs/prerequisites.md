# One-time local setup

This project needs four CLIs. All of them ship as plain static binaries —
no system package manager (and no `sudo`) required.

```bash
mkdir -p ~/.local/bin   # make sure it's on your PATH

# Terraform
curl -fsSL -o terraform.zip \
  https://releases.hashicorp.com/terraform/1.16.6/terraform_1.16.6_linux_amd64.zip
unzip -o -q terraform.zip terraform && mv terraform ~/.local/bin/ && chmod +x ~/.local/bin/terraform

# kubectl
KVER=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -fsSL -o kubectl "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl"
chmod +x kubectl && mv kubectl ~/.local/bin/

# kind
KIND_VER=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])")
curl -fsSL -o kind "https://kind.sigs.k8s.io/dl/${KIND_VER}/kind-linux-amd64"
chmod +x kind && mv kind ~/.local/bin/

# helm
HELM_VER=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])")
curl -fsSL -o helm.tar.gz "https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz"
tar xzf helm.tar.gz && mv linux-amd64/helm ~/.local/bin/ && chmod +x ~/.local/bin/helm
```

You also need Docker running (`kind` creates the cluster's nodes as Docker
containers).

Verify everything:

```bash
terraform version && kubectl version --client && kind version && helm version
```
