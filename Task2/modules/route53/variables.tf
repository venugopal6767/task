# route53/variables.tf
variable "domain_name" {
  description = "The domain name for the existing hosted zone"
  type        = string
}

variable "subdomain_1_name" {
  description = "First subdomain name"
  type        = string
}

variable "subdomain_2_name" {
  description = "Second subdomain name"
  type        = string
}

# These variables should accept ALB DNS name and Zone ID.
variable "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "The zone ID of the Application Load Balancer"
  type        = string
}
