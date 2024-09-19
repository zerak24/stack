locals {
  config         = yamldecode(file("project.yaml")) 
  profile        = local.config.terraform_config.profile
  zone           = local.config.terraform_config.zone
  bucket         = local.config.terraform_config.bucket
  dynamodb_table = local.config.terraform_config.dynamodb_table
}

remote_state {
  backend          = "s3"
  generate         = {
    path           = "backend.tf"
    if_exists      = "overwrite_terragrunt"
  }
  config           = {
    bucket         = local.bucket
    profile        = local.profile
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.zone
    encrypt        = true
    dynamodb_table = local.dynamodb_table
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.zone}"
  profile = "${local.profile}"
}
EOF
}

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