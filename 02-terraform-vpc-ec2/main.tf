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

data "aws_availability_zones" "available" {
  state = "available"
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


}

resource "aws_vpc" "lab" {

  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "asrar-vpc-lab"
  }


}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id
  tags = {
    Name = "asrar-lab-igw"
  }

}

resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.42.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "asrar-public-subnet"
  }


}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id
  tags = {
    Name = "asrar-public-routes"
  }

}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {

  name_prefix = "asrar-vpc-web-"
  vpc_id      = aws_vpc.lab.id
  ingress {
    description = "HTTP"
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

  tags = {
    Name = "asrar-vpc-web-sg"
  }


}

resource "aws_instance" "web" {

  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }

  user_data  = file("${path.module}/../01-ec2-linux-web-server/user-data.sh")
  depends_on = [aws_route.internet]
  tags = {
    Name = "asrar-vpc-web-lab", Project = "aws-cloud-portfolio"
  }


}

output "vpc_id" {
  value = aws_vpc.lab.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "url" {
  value = "http://${aws_instance.web.public_ip}"
}

