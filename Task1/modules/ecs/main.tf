# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "main-ecs-cluster"
}

resource "aws_ecs_task_definition" "service_80_task" {
  family                   = "service-80-task"
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_execution_role_arn
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
      # Non-sensitive variables
      {
        name  = "WORDPRESS_DB_HOST"
        value = var.rds_endpoint  # RDS instance endpoint
      }
    ]
    secrets = [
      # Sensitive variables (MySQL credentials and DB name) from Secrets Manager
      {
        name      = "WORDPRESS_DB_USER"   # Environment variable for DB username
        valueFrom = "${var.secrets_manager_arn}:username::"  # Reference the username from Secrets Manager
      },
      {
        name      = "WORDPRESS_DB_PASSWORD"   # Environment variable for DB password
        valueFrom = "${var.secrets_manager_arn}:password::"  # Reference the password from Secrets Manager
      },
      {
        name      = "WORDPRESS_DB_NAME"   # Environment variable for DB name
        valueFrom = "${var.secrets_manager_arn}:db_name::"  # Reference the db_name from Secrets Manager
      }
    ]
  }])
}


resource "aws_ecs_task_definition" "service_3000_task" {
  family                   = "service-3000-task"
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_execution_role_arn
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

# ECS Service for Service 80 (nginx:latest on port 80)
resource "aws_ecs_service" "service_80" {
  name            = "wordpress"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service_80_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet1_id, var.private_subnet2_id]
    security_groups = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.service_80_target_group
    container_name   = "service-80-container"
    container_port   = 80
  }
}

# ECS Service for Service 3000 (microservice: on port 3000)
resource "aws_ecs_service" "service_3000" {
  name            = "microservice"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service_3000_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet1_id, var.private_subnet2_id]
    security_groups = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.service_3000_target_group
    container_name   = "service-3000-container"
    container_port   = 3000
  }
}
