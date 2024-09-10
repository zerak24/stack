include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:zerak24/terraform_modules.git//aws/vault"
}

locals {
  vars        = yamldecode(file("variables.yaml"))
  project_cfg = yamldecode(file(find_in_parent_folders("project.yaml")))
  users_cfg   = yamldecode(file(find_in_parent_folders("users.yaml")))
  auth_cfg    = yamldecode(file("${local.project_cfg.project.auth_directory}/auth.yaml"))
}

inputs = merge(local.vars, local.project_cfg, local.users_cfg, local.auth_cfg)