module "bucket-cdn" {
  for_each = {
    for idx, object in var.inputs :
    idx => object
  }
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/lb"
  project_id = var.project.project_id
  region     = var.project.region
  name = each.value.name
  cdn_domain = each.value.cdn_domain

}
