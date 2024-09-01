resource "vault_mount" "mount" {
  path        = "example"
  type        = "kv-v2"
  options = {
    version = "2"
    type    = "kv-v2"
  }
  description = "This is an example KV Version 2 secret engine mount"
}

resource "vault_policy" "policy" {
  name = "team-a"

  policy = <<EOT
path "secret/my_app" {
  capabilities = ["update"]
}
EOT
}

locals {
  configs = yamldecode(file("../../../../config.yaml"))
}


resource "vault_identity_oidc" "gitlab" {
  issuer = local.config.gitlab.url
}