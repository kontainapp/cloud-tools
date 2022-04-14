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
      source  = "hashicorp/aws"
      version = "4.9.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # access_key = "provide-ur-access-key"
  # secret_key = "provide-ur-secret-key"
}

variable "ktrial_vm_instance_id" {
  description = "Kontain Trial VM id"
  default     = "i-05727109656d88b00" # amazon linux 2
}

resource "aws_ami_from_instance" "ktrial_ami" {
  name               = "kontain-trial-ami"
  source_instance_id = var.ktrial_vm_instance_id

  tags = {
    name           = "Kontain Trial"
    resource_group = "trial"
  }
}

output "ktrial_ami_id" {
  value = aws_ami_from_instance.ktrial_ami.id
}
