include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:zerak24/terraform_aws_modules.git//role"
}

locals {
  vars        = yamldecode(file("variables.yaml"))
  project_cfg = yamldecode(file(find_in_parent_folders("project.yaml")))
}

inputs = merge(local.vars, {
  project = local.project_cfg.project
})