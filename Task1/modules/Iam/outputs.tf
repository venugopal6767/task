# Output the ECS Execution Role ARN
output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}