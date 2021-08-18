provider "aws" {
  version = "~> 2.0"
  region  = var.default_region
}

terraform {
  required_version = "~> 0.12.0"
}

data "aws_iam_role" "task_ecs" {
  name = "ecsTaskExecutionRole"
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"
}


