module "workload-identity" {
  source        = "git@github.com:zerak24/terraform_modules.git//gcp/workload-identity"
  project_id    = var.project.project_id
  prefix        = var.inputs.sa.prefix
}

module "pubsub" {
  source = "git@github.com:zerak24/terraform_modules.git//gcp/pubsub"
}