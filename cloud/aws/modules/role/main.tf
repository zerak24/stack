locals {
  tags = {
    Terraform   = "true"
    Environment = var.project.env
  }
}

module "iam_eks_role" {
  count     = var.eks-sa == null ? 0 : 1
  source    = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-eks-role?ref=v5.44.0"

  role_name   = format("%s-%s-%s", var.project.company, var.project.env, var.eks-sa.name)

  cluster_service_accounts = var.eks-sa.cluster_service_accounts

  tags = local.tags

  role_policy_arns = merge(var.eks-sa.role_policy_arns, {
      addition_arn =  try(module.iam_policy[0].arn, "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly")
    },
  )

  depends_on = [module.iam_policy]
}

module "iam_policy" {
  count     = var.eks-sa.iam_policy == null ? 0 : 1
  source    = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.44.0"

  name        = format("%s-%s-%s", var.project.company, var.project.env, var.eks-sa.iam_policy.name)
  path        = format("/%s/%s/", var.project.company, var.project.env)

  policy = var.eks-sa.iam_policy.policy

  tags = local.tags
}