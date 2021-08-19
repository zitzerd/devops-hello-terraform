

#Internet Gateway for the VPC
#Since we are working on an existing VPC (which is teh default) it already has an access gateway. We are mapping it so we add the tag.
resource "aws_internet_gateway" "gateway" {
  #imported Values
  vpc_id = data.aws_vpc.default_vpc.id
  tags = {
    Name = "${var.app_name} Internet Gateway"
  }
}

#A route on the main routing table to forward all non local (172.31.0.0/16) to internet
##TODO Check si la importamos o se pisa
resource "aws_route" "internet_access" {
  route_table_id         = data.aws_vpc.default_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id

}

#Mapped resoruces with terraform import so i use teh provided subnets
#Private Subnets
resource "aws_subnet" "private-0" {
  vpc_id                          = data.aws_vpc.default_vpc.id
  assign_ipv6_address_on_creation = false
  availability_zone               = var.availability_zone_names[0]
  cidr_block                      = "172.31.64.0/21"
  map_public_ip_on_launch         = false
  tags = {
    Name   = "${var.app_name} Private subnet 0"
    Public = false
  }
}

resource "aws_subnet" "private-1" {
  vpc_id                          = data.aws_vpc.default_vpc.id
  assign_ipv6_address_on_creation = false
  availability_zone               = var.availability_zone_names[1]
  cidr_block                      = "172.31.128.0/21"
  map_public_ip_on_launch         = false
  tags = {
    Name        = "${var.app_name} Private subnet 1"
    Application = var.app_name
    Public      = false
  }
}

#Public Subnets
resource "aws_subnet" "public-0" {
  vpc_id                          = data.aws_vpc.default_vpc.id
  assign_ipv6_address_on_creation = false
  availability_zone               = var.availability_zone_names[0]
  cidr_block                      = "172.31.32.0/20"
  map_public_ip_on_launch         = true
  tags = {
    Name        = "${var.app_name} Public subnet 0"
    Application = var.app_name
    Public      = true
  }
}

resource "aws_subnet" "public-1" {
  vpc_id                          = data.aws_vpc.default_vpc.id
  assign_ipv6_address_on_creation = false
  availability_zone               = var.availability_zone_names[1]
  cidr_block                      = "172.31.0.0/20"
  map_public_ip_on_launch         = true
  tags = {
    Application = var.app_name
    Name        = "${var.app_name} Public subnet 1"
    Public      = true
  }
}

#Check si lo vamos a usar
//Define the elastic ips that will be linked to the internet gateway
resource "aws_eip" "gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
  tags = {
    Name = "${var.app_name} Elastic IP for Internet Gateway"
    Application = var.app_name
  }
}

//Create a NAT Gateway to allow access from internet to the private IPs of the public subnets
resource "aws_nat_gateway" "gateway" {
  count         = 2
  subnet_id     = element(var.public_subnets.*, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
  tags = {
    Application = var.app_name
    Name = "${var.app_name} Nat Gateway ${count.index}"
  }
}

//Creates 2 routing tables sending all non local traffic to internet from the private subnet
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = data.aws_vpc.default_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }

  tags = {
    Application = var.app_name
    Name = "${var.app_name} ECS Private Route Table ${count.index}"
  }
}

//Associate the private route table we just created for internet access into the subnet
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(var.private_subnets.*, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)  
}

// Create a Security Group for the load balancer that will allow external access only to port 80 and allow outgoing traffic to any destination protocolo/port
resource "aws_security_group" "alb" {
  name        = "lb-sg"
  vpc_id      = data.aws_vpc.default_vpc.id
  description = "Allow inbound  access to the Load Balancer (ALB) on port 80. No outgoing restrictions"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = var.app_name
    Name = "${var.app_name} ALB Security Group"
  }
}



//Create a Security group for the tasks running on the cluster. This SG will only allow traffic comming from the LB on port defined thats the port our tasks listen and expose.
//Analizar como es el link... del ingres al security group del loadb
resource "aws_security_group" "service_access" {
  name        = "ecs-service-sg"
  vpc_id      = data.aws_vpc.default_vpc.id
  description = "Allow inbound access from the Load Balancer (ALB) only, on the application port (5000). No outgoing restrictions"

  ingress {
    protocol        = "tcp"
    from_port       = var.task_port
    to_port         = var.task_port
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = var.app_name
    Name        = "${var.app_name} ECS-Service Security Group"    
  }
}
