
# Fetch the existing Route 53 hosted zone using domain name
data "aws_route53_zone" "existing_zone" {
  name = var.domain_name  # domain name passed from root module, ensure it ends with a dot (e.g., example.com.)
}

# Create Route 53 alias record for subdomain 1
resource "aws_route53_record" "subdomain_1" {
  zone_id = data.aws_route53_zone.existing_zone.id  # Reference to the fetched hosted zone
  name    = var.subdomain_1_name  # Use the subdomain name passed from root module
  type    = "A"  # Alias record type

  ttl     = 300  # Required TTL for alias record (still necessary)
  
  alias {
    name                   = var.alb_dns_name  # ALB DNS name passed from root module
    zone_id                = var.alb_zone_id   # ALB Zone ID passed from root module
    evaluate_target_health = true
  }
}

# Create Route 53 alias record for subdomain 2
resource "aws_route53_record" "subdomain_2" {
  zone_id = data.aws_route53_zone.existing_zone.id  # Reference to the fetched hosted zone
  name    = var.subdomain_2_name  # Use the subdomain name passed from root module
  type    = "A"  # Alias record type

  ttl     = 300  # Required TTL for alias record (still necessary)
  
  alias {
    name                   = var.alb_dns_name  # ALB DNS name passed from root module
    zone_id                = var.alb_zone_id   # ALB Zone ID passed from root module
    evaluate_target_health = true
  }
}

# Reference to the existing hosted zone
data "aws_route53_zone" "main" {
  name = var.domain_name
}

# Create A records for your services in the existing hosted zone
resource "aws_route53_record" "service_80_record" {
  zone_id = data.aws_route53_zone.main.id
  name    = "service1.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "service_3000_record" {
  zone_id = data.aws_route53_zone.main.id
  name    = "service2.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}