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
resource "aws_lb_target_group" "target_group-1" {
  name        = "Instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

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
resource "aws_lb_target_group" "target_group-2" {
  name        = "Docker"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    interval                = 30
    path                    = "/"
    protocol                = "HTTP"
    timeout                 = 5
    healthy_threshold       = 2
    unhealthy_threshold     = 2
  }
}


# Attach EC2 instances to Target Group 1 (nginx - Port 80)
resource "aws_lb_target_group_attachment" "tg_1_ec2_attachment" {
  count             = length(var.instance_ids)  # Attach EC2 instances to WordPress target group
  target_group_arn  = aws_lb_target_group.target_group-1.arn
  target_id         = element(var.instance_ids, count.index)
  port              = 80
}

# Attach EC2 instances to Target Group 2 (Docker - Port 8080)
resource "aws_lb_target_group_attachment" "tg_2_ec2_attachment" {
  count             = length(var.instance_ids)  # Attach EC2 instances to Docker target group
  target_group_arn  = aws_lb_target_group.target_group-2.arn
  target_id         = element(var.instance_ids, count.index)
  port              = 8080
}

# # ALB Listener for HTTP routing based on Host Header
# resource "aws_lb_listener" "http_listener" {
#   load_balancer_arn = aws_lb.app_lb.arn
#   port              = 80
#   protocol          = "HTTP"

#   # Default action
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group-1.arn
#   }
# }

# # Add routing rules based on domain (host)
# resource "aws_lb_listener_rule" "target_group-1" {
#   listener_arn = aws_lb_listener.http_listener.arn
#   priority     = 100  # WordPress routing rule with higher priority

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group-1.arn
#   }

#   condition {
#     host_header {
#       values = ["ec2-alb-instance.${var.domain_name}"]
#     }
#   }
# }

# resource "aws_lb_listener_rule" "target_group-2" {
#   listener_arn = aws_lb_listener.http_listener.arn
#   priority     = 200  # Nginx routing rule with lower priority

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group-2.arn
#   }

#   condition {
#     host_header {
#       values = ["ec2-alb-docker.${var.domain_name}"]
#     }
#   }
# }

# ALB Listener for HTTP routing with redirection to HTTPS based on Host Header
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  # Redirect HTTP traffic to HTTPS (port 443)
  default_action {
    type = "redirect"
    redirect {
      protocol   = "HTTPS"
      port       = "443"
      status_code = "HTTP_301"  # Permanent redirect
      host       = "#{host}"    # Preserve the original host header
      path       = "/#{path}"   # Preserve the original path
      query      = "#{query}"   # Preserve the original query string
    }
  }
}

# Add routing rules based on domain (host) for WordPress (No need for forwarding in HTTP)
resource "aws_lb_listener_rule" "service_80_routing_nginx" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100  # WordPress routing rule with higher priority

  # Redirect action for WordPress
  action {
    type = "redirect"
    redirect {
      protocol   = "HTTPS"
      port       = "443"
      status_code = "HTTP_301"  # Permanent redirect
      host       = "wordpress.${var.domain_name}"  # Redirect to WordPress subdomain on HTTPS
      path       = "/#{path}"   # Preserve the original path
      query      = "#{query}"   # Preserve the original query string
    }
  }

  condition {
    host_header {
      values = ["wordpress.${var.domain_name}"]
    }
  }
}

# Add routing rules based on domain (host) for Nginx (No need for forwarding in HTTP)
resource "aws_lb_listener_rule" "service_8000_routing_docker" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 200  # Nginx routing rule with lower priority

  # Redirect action for Nginx
  action {
    type = "redirect"
    redirect {
      protocol   = "HTTPS"
      port       = "443"
      status_code = "HTTP_301"  # Permanent redirect
      host       = "microservice.${var.domain_name}"  # Redirect to Nginx subdomain on HTTPS
      path       = "/#{path}"   # Preserve the original path
      query      = "#{query}"   # Preserve the original query string
    }
  }

  condition {
    host_header {
      values = ["microservice.${var.domain_name}"]
    }
  }
}


# ALB Listener for HTTPS routing based on Host Header
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:us-east-1:241533153772:certificate/9e9af080-1d9e-4d1f-944a-fb1358bd37da"  # Add the ARN of your SSL certificate

  # Default action
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group-1.arn
  }
}

# Add routing rules based on domain (host) for WordPress
resource "aws_lb_listener_rule" "service_80_routing_nginx_https" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100  # WordPress routing rule with higher priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group-1.arn
  }

  condition {
    host_header {
      values = ["wordpress.${var.domain_name}"]
    }
  }
}

# Add routing rules based on domain (host) for Nginx
resource "aws_lb_listener_rule" "service_3000_routing_docker_https" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 200  # Nginx routing rule with lower priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group-2.arn
  }

  condition {
    host_header {
      values = ["microservice.${var.domain_name}"]
    }
  }
}
