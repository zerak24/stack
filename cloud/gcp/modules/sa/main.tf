module "sa" {
  for_each = {
    for idx, object in var.inputs :
    idx => object
  }
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/sa"
  project_id = var.project.project_id
  prefix        = var.project.env
  names         = each.value.name
  description = each.value.description
  project_roles = [for role in each.value.project_roles:
    format("%v=>%v", var.project.project_id, role)
  ]
}