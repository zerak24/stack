module "sa" {
  source        = "git@github.com:zerak24/terraform_modules.git//gcp/sa"
  project_id    = var.project.project_id
  prefix        = var.inputs.sa.prefix
  names         = var.inputs.sa.names
  project_roles = var.inputs.sa.roles
}

module "pubsub" {
  source = "git@github.com:zerak24/terraform_modules.git//gcp/pubsub"
}