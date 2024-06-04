module "storage" {
  for_each = {
    for idx, object in var.inputs :
    idx => object
  }
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/storage"
  project_id = var.project.project_id
  region     = var.project.region
  names      = each.values.name
  prefix     = var.project.env
}