variable "project" {
  type = object({
    env        = string
    key_directory = optional(string)
    company = string
  })
}
variable "vpc" {
  type = object({
    cidr = string
    zones = list(string)
    public_subnets = list(string)
    public_subnet_tags = map(string)
    private_subnets = list(string)
    private_subnet_tags = map(string)
    database_subnets = list(string)
    single_nat_gateway = bool
  })
  default = null
}
variable "ec2" {
  type = map(object({
    instance_type = string
    ami = optional(string)
    zone = string
    create_key = optional(bool, false)
    key_name = optional(string)
    vpc_security_group_ids = list(string)
  }))
  default = {}
}
variable "sg" {
  type = map(object({
    description = optional(string)
    ingress_with_cidr_blocks = list(any)
  }))
  default = {}
}
variable "rds" {
  type = map(object({
    engine = string
    engine_version = string
    instance_class = string
    security_groups = list(string)
  }))
  default = {}
}
variable "eks" {
  type = object({
    version = string
    aws_auth_roles = optional(list(any))
    aws_auth_users = optional(list(any))
    kms_key_administrators = list(string)
    cluster_service_ipv4_cidr = string
    access_entries = optional(map(object({
      kubernetes_groups = list(string)
      principal_arn = string
      user_name = string
    })))
    eks_managed_node_groups = optional(map(object({
      min_size = number
      max_size = number
      desired_size = number
      ami_type = optional(string)
      instance_types = list(string)
      capacity_type  = string
      iam_role_additional_policies = map(string)
      create_node_security_group = optional(bool, false)
      use_custom_launch_template = optional(bool, true)
      block_device_mappings = optional(map(object({
        device_name = string
        ebs = object({
          volume_size = number
          volume_type = string
          delete_on_termination = bool
          })
        })), {})
      labels = map(string)
      tags = optional(map(string))
      zone = string
      taints = optional(any)
      custom_disk_size = optional(bool, false)  
      })))
    cluster_security_group_additional_rules = optional(object({}))
    taints = optional(object({}))
    cluster_enabled_log_types = optional(any)
  })
  default = null
}