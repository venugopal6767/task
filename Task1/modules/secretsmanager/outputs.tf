output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.rds_secret.arn
}

output "secret_name" {
  description = "The name of the secret"
  value       = aws_secretsmanager_secret.rds_secret.name
}