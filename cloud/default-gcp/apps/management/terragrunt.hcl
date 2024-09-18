include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:zerak24/terraform_gcp_modules.git//role"
}

locals {
  vars        = yamldecode(file("variables.yaml"))
  pre_project_cfg = yamldecode(file(find_in_parent_folders("project.yaml")))
  project_cfg = {
    project = merge(local.pre_project_cfg.project, {
      project_id = local.pre_project_cfg.terraform_config.project
      region = local.pre_project_cfg.terraform_config.zone
    })
  }
}

inputs = merge(local.vars, local.project_cfg)