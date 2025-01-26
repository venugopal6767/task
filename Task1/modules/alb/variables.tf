variable "domain_name" {
  description = "The security group ID for ECS tasks"
  type        = string
}

variable "vpc_id" {
  description = "The security group ID for ECS tasks"
  type        = string
}

variable "ecs_security_group_id" {
  description = "The security group ID for ECS tasks"
  type        = string
}

variable "public_subnet1_id" {
  description = "ID of the first private subnet"
  type        = string
}

variable "public_subnet2_id" {
  description = "ID of the second private subnet"
  type        = string
}
