locals {
  config         = yamldecode(file("project.yaml")) 
  project        = local.config.terraform_config.project
  zone           = local.config.terraform_config.zone
  bucket         = local.config.terraform_config.bucket
}

remote_state {
  backend          = "gcs"
  generate         = {
    path           = "backend.tf"
    if_exists      = "overwrite_terragrunt"
  }
  config           = {
    bucket         = local.bucket
    project        = local.project
    prefix         = "${path_relative_to_include()}/terraform.tfstate"
    location       = local.zone
  }
}

// generate "provider" {
//   path      = "provider.tf"
//   if_exists = "overwrite_terragrunt"
//   contents  = <<EOF
// provider "google" {
//   region  = "${local.zone}"
//   project = "${local.project}"
// }
// EOF
// }

terraform {
  extra_arguments "common_vars" {
    commands = [
      "apply",
      "plan",
      "destroy"
    ]
  }

  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=3m"]
  }
}