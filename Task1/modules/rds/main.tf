data "aws_secretsmanager_secret" "rds_secret" {
  arn = var.secret_arn
}

data "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}

locals {
  secret_data = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)
}


# Create DB Subnet Group
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name        = "my-db-subnet"
  description = "Private subnets for RDS instance"
  subnet_ids  = [var.private_subnet1_id, var.private_subnet2_id]  # Replace with actual private subnet IDs

  tags = {
    Name = "MyDBSubnetGroup"
  }
}

resource "aws_db_instance" "mydb_instance" {
  identifier              = "wordpress-db-instance"
  allocated_storage       = 20  # Storage size in GB
  storage_type            = "gp2"  # General Purpose SSD
  engine                  = "mysql"
  engine_version          = "8.0"  # Replace with your preferred MySQL version
  instance_class          = "db.t3.micro"  # Instance type
  db_name                 = local.secret_data["db_name"]  # Database name
  username                = local.secret_data["username"]
  password                = local.secret_data["password"]
  parameter_group_name    = "default.mysql8.0"  # MySQL parameter group for version 8.0
  skip_final_snapshot     = true  # Set to false for production environments to create a snapshot on deletion
  multi_az                = false  # Set to true for multi-AZ deployment (high availability)
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids  = [var.security_group_id]
  backup_retention_period = 7  # Retain backups for 7 days
  tags = {
    Name = "MyDBInstance"
  }
}
