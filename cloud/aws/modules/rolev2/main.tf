locals {
  tags = {
    Terraform   = "true"
    Environment = var.project.env
  }
}
module "role" {
  count     = var.role == null ? 0 : 1
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks-pod-identity.git?ref=v1.4.0"
  name = format("%s-%s-%s", var.project.company, var.project.env, var.role.name)

  attach_cluster_autoscaler_policy = var.role.attach_cluster_autoscaler_policy
  cluster_autoscaler_cluster_names = var.role.cluster_autoscaler_cluster_names

  attach_aws_lb_controller_policy = var.role.attach_aws_lb_controller_policy

  attach_velero_policy       = var.role.attach_velero_policy
  velero_s3_bucket_arns      = var.role.velero_s3_bucket_arns
  velero_s3_bucket_path_arns = var.role.velero_s3_bucket_path_arns

  trust_policy_conditions = var.role.trust_policy_conditions
  trust_policy_statements = var.role.trust_policy_statements
  attach_custom_policy      = var.role.attach_custom_policy
  policy_statements = var.role.policy_statements
  additional_policy_arns = var.role.additional_policy_arns
  tags = local.tags
}
