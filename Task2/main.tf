terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify the AWS provider version
    }
  }

  required_version = ">= 1.5.0" # Ensure Terraform version compatibility
}

provider "aws" {
  region = var.region # AWS region to deploy resources
}

module "vpc" {
  source             = "./modules/vpc"
  name               = "demo"
  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

# Security Group allowing all traffic
resource "aws_security_group" "all_traffic_sg" {
  name        = "all-traffic-sg"
  description = "Security group allowing all inbound and outbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"       # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from all IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"       # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to all IPs
  }

  tags = {
    Name = "all-traffic-sg"
  }
}

module "ec2" {
  source          = "./modules/ec2"
  ami             = "ami-04b4f1a9cf54c11d0" # Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  private_subnets = module.vpc.private_subnets
  key_name        = "venu-test"
  user_data       = file("${path.root}/userdata.sh") # Use the userdata.sh file from root
  name            = "demo"
  security_groups = [aws_security_group.all_traffic_sg.id] # Add the all-traffic SG
}


module "alb" {
  source              = "./modules/alb"
  alb_name            = "my-application-lb"
  security_groups     = [aws_security_group.all_traffic_sg.id]
  subnets             = module.vpc.public_subnets
  vpc_id              = module.vpc.vpc_id
  tags                = { Name = "my-alb" }
  target_group_1_name = "tg-1"
  target_group_2_name = "tg-2"
  ec2_instance_ids    = module.ec2.instance_ids  # Pass EC2 instance IDs here
}


