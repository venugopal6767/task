# ALB DNS Name Output
output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

# ALB Zone ID Output
output "alb_zone_id" {
  value = aws_lb.this.zone_id
}