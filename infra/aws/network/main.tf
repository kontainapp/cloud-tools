# module for defining VPC and subnet and security group for trial instances
#----
variable "region" {
    description = "Region for Kontain trial"
    default = "us-east-1"
}

variable "cidr_block" {
  description = "CIDR block for Kontain trial VPC"
  default = "10.0.0.0/16"
}

#----
provider "aws" {
  region     = "${var.region}"
  # access_key = "provide-ur-access-key"
  # secret_key = "provide-ur-secret-key"
}

#----
resource "aws_vpc" "ktrial_vpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true
  

  tags = {
    name = "Kontain Trial VPC"
    resource_group = "trial"
  }
}

resource "aws_subnet" "ktrial_public_subnet" {
  vpc_id            = aws_vpc.ktrial_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    name = "Kontain Public Subnet"
    resource_group = "trial"
  }
}

#----
resource "aws_internet_gateway" "ktrial_ig" {
  vpc_id = aws_vpc.ktrial_vpc.id

  tags = {
    name = "Kontain Trial Internet Gateway"
    resource_group = "trial"
  }
}

#----
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ktrial_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ktrial_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.ktrial_ig.id
  }

  tags = {
    name = "Kontain Trial Public Route Table"
    resource_group = "trial"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.ktrial_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

#----
resource "aws_security_group" "ktrial_sg" {
  name = "KontainTrial VM security group"

  # delete this line if you want security group in the "default" VPC
  vpc_id = aws_vpc.ktrial_vpc.id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "80 from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "443 from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "8080 from the internet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "8443 from the internet"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "5000 from the internet"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "Kontain Trial Security Group"
    resource_group = "trial"
  }
}

#----
output "ktrial_vpc_id" {
    value = aws_vpc.ktrial_vpc.id
}

output "ktrial_sg_id" {
    value = aws_security_group.ktrial_sg.id
}

output "ktrial_subnet_public_id" {
    value = aws_subnet.ktrial_public_subnet.id
}