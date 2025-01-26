provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "alb" {
    source                    = "./modules/alb"
    domain_name               = "venugopalmoka.site"
    vpc_id                    = module.vpc.vpc_id
    ecs_security_group_id     = module.vpc.security_group_id
    public_subnet1_id         = module.vpc.public_subnet_1_id
    public_subnet2_id         = module.vpc.public_subnet_2_id
    instance_ids              = module.ec2.private_instance_ids 
    
}

module "route53" {
  source = "./modules/route53"
  domain_name = "venugopalmoka.site"
  zone_id = module.alb.alb_zone_id
  alb_dns_name = module.alb.alb_dns_name
}

module "ec2" {
  source          = "./modules/ec2"
  ami             = "ami-04b4f1a9cf54c11d0" # Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  private_subnets = module.vpc.private_subnets
  key_name        = "venu-test"
  user_data       = filebase64("${path.root}/userdata.sh") # Use the userdata.sh file from root
  name            = "demo"
  security_groups = module.vpc.security_group_id # Add the all-traffic SG
  depends_on = [module.vpc]
}