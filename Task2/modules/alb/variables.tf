variable "alb_name" {
  description = "The name of the Application Load Balancer"
  type        = string
}

variable "security_groups" {
  description = "Security groups to attach to the load balancer"
  type        = list(string)
}

variable "subnets" {
  description = "Subnets to attach to the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the ALB and target groups will be created"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}

variable "target_group_1_name" {
  description = "Name of the first target group"
  type        = string
}

variable "target_group_2_name" {
  description = "Name of the second target group"
  type        = string
}

variable "ec2_instance_ids" {
  description = "List of EC2 instance IDs to attach to the target groups"
  type        = list(string)
}
