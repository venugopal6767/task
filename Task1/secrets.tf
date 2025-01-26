# Data source to retrieve the 'wordpress-db-credentials' secret using its ARN
data "aws_secretsmanager_secret" "wordpress_db_credentials" {
  arn = "arn:aws:secretsmanager:us-east-1:241533153772:secret:wordpress-db-credentials-qigJ7r"  # Secret ARN
}

# Retrieve the version of the 'wordpress-db-credentials' secret
data "aws_secretsmanager_secret_version" "wordpress_db_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.wordpress_db_credentials.id
}

# Decode the secret (assumes it's stored as a JSON object)
locals {
  secret_values = jsondecode(data.aws_secretsmanager_secret_version.wordpress_db_credentials_version.secret_string)
}

# Output the specific values
output "db_name" {
  value     = local.secret_values["DB_NAME"]
  sensitive = true
}

output "db_user" {
  value     = local.secret_values["DB_USER"]
  sensitive = true
}

output "db_password" {
  value     = local.secret_values["DB_PASSWORD"]
  sensitive = true
}