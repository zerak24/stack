module "service_accounts" {
  for_each = {
    for idx, obj in var.inputs:
    idx => obj
  }
  source        = "../../modules/sa"
  project_id    = var.project.project_id
  prefix        = each.value.prefix
  names         = each.value.names
  project_roles = each.value.roles
}