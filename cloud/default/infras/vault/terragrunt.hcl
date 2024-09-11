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
  auth_cfg    = yamldecode(file(abspath("${local.project_cfg.project.auth_file}")))
}

inputs = merge(local.vars, local.users_cfg, {
  project = local.project_cfg.project
}, {
  vault_auth = local.auth_cfg.vault_auth
})