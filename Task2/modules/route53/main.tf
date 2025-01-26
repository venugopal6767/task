# Reference to the existing hosted zone
data "aws_route53_zone" "main" {
  name = var.domain_name
}

# Create A records for your services in the existing hosted zone
resource "aws_route53_record" "target_group-1" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "ec2-alb-instance.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.zone_id 
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "target_group-2" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "ec2-alb-docker.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.zone_id 
    evaluate_target_health = true
  }
}
