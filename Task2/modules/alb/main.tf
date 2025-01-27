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


# Attach EC2 instances to Target Group 1 (WordPress - Port 80)
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

# ALB Listener for HTTP routing based on Host Header
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  # Default action
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group-1.arn
  }
}

# Add routing rules based on domain (host)
resource "aws_lb_listener_rule" "target_group-1" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100  # WordPress routing rule with higher priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group-1.arn
  }

  condition {
    host_header {
      values = ["ec2-alb-instance.${var.domain_name}"]
    }
  }
}

resource "aws_lb_listener_rule" "target_group-2" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 200  # Nginx routing rule with lower priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group-2.arn
  }

  condition {
    host_header {
      values = ["ec2-alb-docker.${var.domain_name}"]
    }
  }
}
