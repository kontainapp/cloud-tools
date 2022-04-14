# # picks latest amazon-linux-2 AMI
# data "aws_ami" "amazon-linux-2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
# }

#----
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.9.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  # access_key = "provide-ur-access-key"
  # secret_key = "provide-ur-secret-key"
}

variable "ami" {
    description = "AMI Amazon Linux 2 for instance"
    default = "ami-039fd8d5038bca8b2" # ktrial_vm
}

variable "instance_type" {
    description = "Instance size for EC2 VM"
    default = "t3.small"
}

variable "ktrial_vpc_id" {
  description = "Kontain Trial VPC id"
  default = "vpc-083d4bcb385608c2c"
}

variable "ktrial_sg_id" {
  description = "Kontain Trial Security group id"
  default = "sg-0d01843eb92aa8e17"
}

variable "ktrial_public_subnet_id" {
  description = "Kontain Trial public subnet id"
  default = "subnet-0a1bf12338e68d60e"
}

variable "ktrial_key_name" {
  description = "Kontain Trial instance key"
  default = "ktrial"
}

#----
resource "aws_instance" "trial1" {
	ami = "${var.ami}"
	instance_type = "${var.instance_type}"

  # key for accessing instance
	key_name = "${var.ktrial_key_name}"

  # network related
  subnet_id = "${var.ktrial_public_subnet_id}" # aws_subnet.kontain_public_subnet.id
  vpc_security_group_ids = ["${var.ktrial_sg_id}"] # [aws_security_group.ktrial_sg.id]
  associate_public_ip_address = true

    # root disk
    root_block_device {
        volume_size           = "50"
        # volume_type           = "gp2"
        # encrypted             = true
        delete_on_termination = true
    }

	tags = {
		name = "Kontain Trial Instance"
    resource_group = "trial instances"
	}
}

output "instance_id" {
    value = aws_instance.trial1.id
}

output "instance_public_ip" {
    value = aws_instance.trial1.public_ip
}

output "instance_public_dns" {
    value = aws_instance.trial1.public_dns
}
