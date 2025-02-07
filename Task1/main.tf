provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "Iam" {
    source                    = "./modules/Iam"
    secrets_manager_arn       = module.secretsmanager.secret_arn
}

module "ecs" {
    source = "./modules/ecs"
    ecs_execution_role_arn    = module.Iam.ecs_execution_role_arn
    ecs_security_group_id     = module.vpc.security_group_id
    private_subnet1_id        = module.vpc.private_subnet_1_id
    private_subnet2_id        = module.vpc.private_subnet_2_id
    service_80_target_group   = module.alb.service_80_target_group
    service_3000_target_group = module.alb.service_3000_target_group
    rds_endpoint              = module.rds.rds_endpoint
    secrets_manager_arn       = module.secretsmanager.secret_arn
    depends_on                = [module.secretsmanager]
}

module "alb" {
    source                    = "./modules/alb"
    domain_name               = "venugopalmoka.site"
    vpc_id                    = module.vpc.vpc_id
    ecs_security_group_id     = module.vpc.security_group_id
    public_subnet1_id         = module.vpc.public_subnet_1_id
    public_subnet2_id         = module.vpc.public_subnet_2_id
    
}

module "route53" {
  source = "./modules/route53"
  domain_name = "venugopalmoka.site"
  zone_id = module.alb.alb_zone_id
  alb_dns_name = module.alb.alb_dns_name
}

module "secretsmanager" {
    source = "./modules/secretsmanager"
    secret_name = "mydb/credentials1"
    db_username  = "admin"
    db_name = "wordpress"
}

module "rds" {
    source = "./modules/rds"
    secret_arn            = module.secretsmanager.secret_arn
    security_group_id     = module.vpc.security_group_id
    private_subnet1_id    = module.vpc.private_subnet_1_id
    private_subnet2_id    = module.vpc.private_subnet_2_id
    depends_on = [module.secretsmanager]
}