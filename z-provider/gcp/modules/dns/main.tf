module "dns" {
  source                             = "git@github.com:zerak24/terraform_modules.git//gcp/dns"
  project_id                         = var.project.project_id
  type                               = "public"
  name                               = var.inputs.name
  domain                             = var.inputs.domain
  private_visibility_config_networks = []
  recordsets                         = var.inputs.recordsets
}