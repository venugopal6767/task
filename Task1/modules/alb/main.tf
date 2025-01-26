# Application Load Balancer (ALB)
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [var.ecs_security_group_id]
  subnets            = [var.public_subnet1_id, var.public_subnet2_id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}

# Target Group for Service 80 (wordpress:latest on port 80)
resource "aws_lb_target_group" "service_80_target_group" {
  name        = "service-80-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval                = 30
    path                    = "/"
    protocol                = "HTTP"
    timeout                 = 5
    healthy_threshold       = 2
    unhealthy_threshold     = 2
  }
}

# Target Group for Service 3000 (:latest on port 3000)
resource "aws_lb_target_group" "service_3000_target_group" {
  name        = "service-3000-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval                = 30
    path                    = "/"
    protocol                = "HTTP"
    timeout                 = 5
    healthy_threshold       = 2
    unhealthy_threshold     = 2
  }
}

# ALB Listener for HTTP routing based on Host Header
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  # Default action
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_80_target_group.arn
  }
}

# Add routing rules based on domain (host)
resource "aws_lb_listener_rule" "service_80_routing" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100  # WordPress routing rule with higher priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_80_target_group.arn
  }

  condition {
    host_header {
      values = ["wordpress.${var.domain_name}"]
    }
  }
}

resource "aws_lb_listener_rule" "service_3000_routing" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 200  # Nginx routing rule with lower priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_3000_target_group.arn
  }

  condition {
    host_header {
      values = ["microservice.${var.domain_name}"]
    }
  }
}
