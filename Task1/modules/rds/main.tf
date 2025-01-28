data "aws_secretsmanager_secret" "rds_secret" {
  arn = var.secret_id
}

data "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}

locals {
  secret_data = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)
}

resource "aws_db_instance" "mydb_instance" {
  identifier           = "wordpress-db-instance"
  allocated_storage    = 20  # Storage size in GB
  storage_type         = "gp2"  # General Purpose SSD
  engine               = "mysql"
  engine_version       = "8.0"  # Replace with your preferred MySQL version
  instance_class       = "db.t3.micro"  # Instance type
  db_name              = local.secret_data["mydb"]  # Database name
  username             = local.secret_data["username"]
  password             = local.secret_data["password"]
  parameter_group_name = "default.mysql8.0"  # MySQL parameter group for version 8.0
  skip_final_snapshot  = true  # Set to false for production environments to create a snapshot on deletion
  multi_az             = false  # Set to true for multi-AZ deployment (high availability)
  publicly_accessible  = true
  
  tags = {
    Name = "MyDBInstance"
  }

  # Optional settings
  backup_retention_period = 7  # Retain backups for 7 days
  db_subnet_group_name     = "default"  # Specify the subnet group if needed
}
