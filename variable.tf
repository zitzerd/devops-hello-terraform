variable default_region {
    default = "eu-west-1"
}

variable availability_zone_names{
  type    = list(string)
  default = []  
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "ecs_execution_role_arn"{}

variable "app_name" {}