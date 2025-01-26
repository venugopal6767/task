# Variables to hold your domain name
variable "domain_name" {
  description = "Your custom domain name"
  default     = "venugopalmoka.site"
}


# IAM Policy to allow ECS task to pull secrets
resource "aws_iam_policy" "ecs_secrets_manager_policy" {
  name        = "ecs-secrets-manager-policy"
  description = "Policy to allow ECS tasks to retrieve secrets from Secrets Manager"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the secrets manager policy to the ECS execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_secrets_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets_manager_policy.arn
}


# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect    = "Allow"
      },
    ]
  })
}

# ECS Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect    = "Allow"
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_ecr_policy" {
  name        = "ecs-ecr-policy"
  description = "Policy to allow ECS to pull images from ECR"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ecr:GetAuthorizationToken"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ecr:BatchGetImage"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ecr:BatchCheckLayerAvailability"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ecr:GetDownloadUrlForLayer"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_ecr_policy.arn
}


# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "main-ecs-cluster"
}

resource "aws_ecs_task_definition" "service_80_task" {
  family                   = "service-80-task"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "service-80-container"
    image     = "wordpress:latest"
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "WORDPRESS_DB_HOST"
        value = aws_db_instance.mydb.endpoint  # Dynamically fetch RDS DB endpoint
      },
      {
        name  = "WORDPRESS_DB_NAME"
        value = local.secret_values["DB_NAME"]  # Fetch database name from the decoded secret
      }
    ]
    secrets = [
      {
        name      = "WORDPRESS_DB_USER"
        valueFrom = "arn:aws:secretsmanager:us-east-1:241533153772:secret:wordpress-db-credentials-qigJ7r:DB_USER"
      },
      {
        name      = "WORDPRESS_DB_PASSWORD"
        valueFrom = "arn:aws:secretsmanager:us-east-1:241533153772:secret:wordpress-db-credentials-qigJ7r:DB_PASSWORD"
      }
    ]
  }])
}


resource "aws_ecs_task_definition" "service_3000_task" {
  family                   = "service-3000-task"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "service-3000-container"
    image     = "241533153772.dkr.ecr.us-east-1.amazonaws.com/custom-image:latest"
    essential = true
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }
    ]
  }])
}

# ALB Security Group
resource "aws_security_group" "app_lb_sg" {
  name        = "app-lb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-service-sg"
  description = "Allow HTTP traffic to ECS service"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow traffic from the ALB to ECS tasks
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app_lb_sg.id]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.app_lb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}

# Target Group for Service 80 (wordpress:latest on port 80)
resource "aws_lb_target_group" "service_80_target_group" {
  name        = "service-80-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
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
  vpc_id      = aws_vpc.main.id
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
      values = ["service1.${var.domain_name}"]
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
      values = ["service2.${var.domain_name}"]
    }
  }
}

# ECS Service for Service 80 (nginx:latest on port 80)
resource "aws_ecs_service" "service_80" {
  name            = "service-80"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service_80_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service_80_target_group.arn
    container_name   = "service-80-container"
    container_port   = 80
  }

  depends_on = [
    aws_lb.app_lb,
    aws_lb_target_group.service_80_target_group
  ]
}

# ECS Service for Service 3000 (wordpress:latest on port 3000)
resource "aws_ecs_service" "service_3000" {
  name            = "service-3000"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service_3000_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service_3000_target_group.arn
    container_name   = "service-3000-container"
    container_port   = 3000
  }

  depends_on = [
    aws_lb.app_lb,
    aws_lb_target_group.service_3000_target_group
  ]
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

# Output the Load Balancer DNS Name
output "load_balancer_dns" {
  value = aws_lb.app_lb.dns_name
}

output "service_80_dns" {
  value = "service1.${var.domain_name}"
}

output "service_3000_dns" {
  value = "service2.${var.domain_name}"
}
