resource "aws_db_instance" "mysql" {
  allocated_storage     = var.allocated_storage
  instance_class        = var.instance_class
  engine                = var.engine
  engine_version        = var.engine_version
  identifier            = var.identifier
  username              = var.username  # MySQL username
  password              = var.password  # Password (can be provided via Secrets Manager)
#   db_name               = var.db_name
  skip_final_snapshot   = true
  multi_az              = var.multi_az
  publicly_accessible   = false
  storage_type          = var.storage_type
  backup_retention_period = var.backup_retention_period
}
