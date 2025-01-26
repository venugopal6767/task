variable "ecs_execution_role_arn" {
  description = "The ARN of the ECS Execution Role"
  type        = string
}

variable "ecs_security_group_id" {
  description = "The security group ID for ECS tasks"
  type        = string
}

variable "private_subnet1_id" {
  description = "ID of the first private subnet"
  type        = string
}

variable "private_subnet2_id" {
  description = "ID of the second private subnet"
  type        = string
}

variable "service_80_target_group" {
  description = "ID of the second private subnet"
  type        = string
}

variable "service_3000_target_group" {
  description = "ID of the second private subnet"
  type        = string
}

variable "rds_endpoint" {
  description = "ID of the second private subnet"
  type        = string
}

variable "secrets_manager_arn" {
  description = "ID of the second private subnet"
  type        = string
}