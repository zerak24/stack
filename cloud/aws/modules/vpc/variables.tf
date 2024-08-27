variable "project" {
  type = object({
    env        = string
  })
}
variable "inputs" {
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