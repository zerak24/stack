module "workload-identity" {
  source        = "git@github.com:zerak24/terraform_modules.git//gcp/workload-identity"
  project_id    = var.project.project_id
  location = var.project.region
  name                = var.inputs.identity.name
  gcp_sa_name = format("%v-%v", var.project.env, var.inputs.identity.name)
  namespace           = var.inputs.identity.namespace
  roles               = var.inputs.identity.roles
  cluster_name = var.project.env
  annotate_k8s_sa = true
  use_existing_k8s_sa = true
}

module "pubsub" {
  for_each = {
    for idx, object in var.inputs :
    idx => object
  }
  source = "git@github.com:zerak24/terraform_modules.git//gcp/pubsub"
  project_id = var.project.project_id
  topic      = each.value.pubsub.topic
  pull_subscriptions = [
    {
      name                         = "pull"
      ack_deadline_seconds         = 10
      enable_exactly_once_delivery = true
    }
  ]
  push_subscriptions = [
    {
      name                 = "push"
      push_endpoint        = "https://${var.project_id}.appspot.com/"
      x-goog-version       = "v1beta1"
      ack_deadline_seconds = 20
      expiration_policy    = "1209600s"
    }
  ]
  cloud_storage_subscriptions = [
    {
      name   = "pubsub_bucket_subscription"
      bucket = each.value.pubsub.storage_name
      ack_deadline_seconds = 300
    }
  ]
}