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
  region  = var.region       # AWS region to deploy resources
}

module "vpc" {
  source             = "./modules/vpc"
  name               = "demo"
  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "ec2" {
  source          = "./modules/ec2"
  ami             = "ami-04b4f1a9cf54c11d0" # Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  private_subnets = module.vpc.private_subnets
  key_name        = "venu-test"
  user_data       = file("userdata.sh")
  name            = "demo"
}
