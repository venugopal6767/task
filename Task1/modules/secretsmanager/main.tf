# modules/secretsmanager/main.tf

resource "aws_secretsmanager_secret" "rds_mysql_secret" {
  name        = "rds_mysql_secret"
  description = "MySQL Database Credentials"
}

resource "aws_secretsmanager_secret_version" "rds_mysql_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_mysql_secret.id
  secret_string = jsonencode({
    DB_PASSWORD = var.db_password
    DB_USER     = var.db_user
  })
}

