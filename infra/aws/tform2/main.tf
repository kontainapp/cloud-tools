# # picks latest amazon-linux-2 AMI
# data "aws_ami" "amazon-linux-2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
# }

variable "ami" {
    description = "AMI for instance"
    default = "ami-0c02fb55956c7d316" # amazon linux 2
}

variable "instance_type" {
    description = "Instance size for EC2 VM"
    default = "t3.small"
}

provider "aws" {
	region = "us-east-1"
    # access_key = "ACCESS_KEY_HERE"
    # secret_key = "SECRET_KEY_HERE"
}

resource "aws_key_pair" "ktrial_demo" {
  key_name   = "smijar@smretina.local"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "ktrial_sg" {
  name = "security group from terraform"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ktrial_instance" {
	ami = "${var.ami}" # fedora 34
	instance_type = "${var.instance_type}"
	key_name = "${aws_key_pair.ktrial_demo.key_name}"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.ktrial_sg.id]

    # root disk
    root_block_device {
        volume_size           = "50"
        volume_type           = "gp2"
        encrypted             = true
        delete_on_termination = true
    }

    user_data = "${file("amznlinux2-cloud-init.sh")}"
    # user_data = <<-EOF
    # #!/bin/bash -ex

    # amazon-linux-extras install nginx1 -y
    # echo "<h1>$(curl https://api.kanye.rest/?format=text)</h1>" >  /usr/share/nginx/html/index.html 
    # systemctl enable nginx
    # systemctl start nginx
    # EOF

	tags = {
		Name = "Kontain Trial"
	}
}

output "instance_public_ip" {
    value = aws_instance.ktrial_instance.public_ip
}

output "instance_public_dns" {
    value = aws_instance.ktrial_instance.public_dns
}
