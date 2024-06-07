module "storage" {
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/storage"
  project_id = var.project.project_id
  region     = var.project.region
}

module "cdn" {
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/lb"
  project_id = var.project.project_id
  region     = var.project.region
}