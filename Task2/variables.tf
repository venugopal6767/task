variable "region" {
  default = "us-east-1"
}

variable "domain_name" {
  description = "The domain name"
  type        = string
  default     = "venugopalmoka.site"  # You can replace this with your domain
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
  default     = ""  # Leave it empty if it's going to be outputted from the module
}

variable "subdomains" {
  description = "The list of subdomains"
  type        = list(string)
  default     = ["my-service", "another-service"]  # Replace with your desired subdomains
}
