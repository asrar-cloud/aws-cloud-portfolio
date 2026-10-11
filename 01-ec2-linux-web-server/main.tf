terraform {

  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source = "hashicorp/aws", version = "~> 5.0"
    }

  }


}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type        = string
  default     = null
  description = "Optional existing EC2 key pair for SSH; prefer Session Manager"
}

variable "ssh_cidr" {
  type        = string
  default     = null
  description = "Optional trusted /32 only; null disables SSH"
}

data "aws_ami" "al2023" {

  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

}

resource "aws_security_group" "web" {

  name_prefix = "asrar-web-"
  description = "Public HTTP; optional restricted SSH"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {

    for_each = var.ssh_cidr == null ? [] : [var.ssh_cidr]
    content {
      description = "SSH from trusted address"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }


  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asrar-web-sg"
  }


}

resource "aws_instance" "web" {

  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }

  user_data = file("${path.module}/user-data.sh")
  tags = {
    Name = "asrar-ec2-web-lab", Project = "aws-cloud-portfolio"
  }


}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "url" {
  value = "http://${aws_instance.web.public_ip}"
}

