# Builds the app image locally and loads it straight into the kind
# cluster's nodes - no registry needed for a local-dev cluster.

locals {
  app_dir = "${path.module}/../app"
  app_source_hash = sha1(join("", [
    filesha1("${local.app_dir}/main.py"),
    filesha1("${local.app_dir}/requirements.txt"),
    filesha1("${local.app_dir}/Dockerfile"),
  ]))
  app_image = "tasks-api:${local.app_source_hash}"
}

resource "terraform_data" "build_app_image" {
  triggers_replace = [local.app_source_hash]

  provisioner "local-exec" {
    command = "docker build -t ${local.app_image} ${local.app_dir}"
  }
}

# The kind provider only models kind_cluster - no resource for loading
# images - so this shells out to the real kind CLI directly.
resource "terraform_data" "load_app_image" {
  triggers_replace = [local.app_source_hash]

  provisioner "local-exec" {
    command = "kind load docker-image ${local.app_image} --name ${kind_cluster.this.name}"
  }

  depends_on = [terraform_data.build_app_image]
}
