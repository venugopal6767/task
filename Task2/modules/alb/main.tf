# modules/alb_module/main.tf

resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets
  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_target_group" "tg_1" {
  name        = var.target_group_1_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
    path = "/healthcheck"
  }

  tags = var.tags
}

resource "aws_lb_target_group" "tg_2" {
  name        = var.target_group_2_name
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
    path = "/healthcheck"
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      message_body = "OK"
      content_type = "text/plain"
    }
  }
}

# Forward Action for Target Group 1 based on Host Header
resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_1.arn
  }

  condition {
    host_header {
      values = ["ec2-alb-instance.venugopalmoka.site"]  # Matching host header pattern
    }
  }
}

# Forward Action for Target Group 2 based on Host Header
resource "aws_lb_listener_rule" "host_based_weighted_routing_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_2.arn
  }

  condition {
    host_header {
      values = ["ec2-alb-docker.venugopalmoka.site"]  # Matching host header pattern for a different target group
    }
  }
}

# Attach EC2 instances to both Target Groups (TG1 and TG2)
resource "aws_lb_target_group_attachment" "tg_1_attachment" {
  count             = length(var.ec2_instance_ids)
  target_group_arn  = aws_lb_target_group.tg_1.arn
  target_id         = element(var.ec2_instance_ids, count.index)
  port              = 80
}

resource "aws_lb_target_group_attachment" "tg_2_attachment" {
  count             = length(var.ec2_instance_ids)
  target_group_arn  = aws_lb_target_group.tg_2.arn
  target_id         = element(var.ec2_instance_ids, count.index)
  port              = 8080
}

output "alb_arn" {
  value = aws_lb.this.arn
}

output "tg_1_arn" {
  value = aws_lb_target_group.tg_1.arn
}

output "tg_2_arn" {
  value = aws_lb_target_group.tg_2.arn
}
