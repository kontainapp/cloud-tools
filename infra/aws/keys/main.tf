# module for defining 1-time key pair for all instances
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

#----
resource "aws_key_pair" "ktrial_demo" {
  key_name   = "ktrial"
  public_key = "${file("~/.ssh/ktrial.pub")}"
}
