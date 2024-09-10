include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:zerak24/terraform_modules.git//aws/role"
}

locals {
  vars        = yamldecode(file("variables.yaml"))
  project_cfg = yamldecode(file(find_in_parent_folders("project.yaml")))
}

inputs = merge(local.vars, local.project_cfg)