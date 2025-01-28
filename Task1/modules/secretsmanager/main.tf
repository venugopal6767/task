resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name        = var.secret_name
  description = "RDS MySQL credentials (username and password)"

  tags = {
    "name" = "rds-secrets"
  }
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.db_username
    db_name  = var.db_name
    password = random_password.password.result
  })
}