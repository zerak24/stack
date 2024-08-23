module "bucket" {
  for_each = {
    for idx, object in var.inputs :
    idx => object
  }
  source          = "git@github.com:zerak24/terraform_modules.git//gcp/bucket"
  project_id      = var.project.project_id
  location        = var.project.region
  name            = format("%v-%v", var.project.env, each.value.name)
  lifecycle_rules = each.value.lifecycle_rules
  cors            = each.value.cors
  iam_members     = each.value.iam_members
  storage_class   = each.value.storage_class
  versioning      = each.value.versioning
  autoclass       = false
}