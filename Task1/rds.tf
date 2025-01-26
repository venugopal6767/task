# Data source to retrieve the 'wordpress-db-credentials' secret using its ARN
data "aws_secretsmanager_secret" "wordpress_db_credentials" {
  arn = "arn:aws:secretsmanager:us-east-1:241533153772:secret:wordpress-db-credentials-qigJ7r"  # Secret ARN
}

# Retrieve the version of the 'wordpress-db-credentials' secret
data "aws_secretsmanager_secret_version" "wordpress_db_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.wordpress_db_credentials.id
}

# Decode the secret (assumes it's stored as a JSON object)
locals {
  secret_values = jsondecode(data.aws_secretsmanager_secret_version.wordpress_db_credentials_version.secret_string)
}

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name       = "mydb-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]  # Reference your subnets here

  tags = {
    Name = "mydb-subnet-group"
  }
}

# Create a new security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "wordpress-db-sg"
  description = "Security group for the WordPress RDS MySQL instance"
  vpc_id      = aws_vpc.main.id  # Make sure to reference the correct VPC ID

  # Ingress rules (allow access to the RDS from your application or other services)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Modify this to match your VPC CIDR block or trusted IPs
  }

  # Egress rules (allow outbound traffic, default is all traffic allowed)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Modify based on your security needs
  }

  tags = {
    Name = "RDS MySQL Security Group"
  }
}

# RDS MySQL instance creation using credentials from Secrets Manager
resource "aws_db_instance" "mydb" {
  identifier              = "wordpress-db-instance"
  instance_class          = "db.t3.micro"   # Adjust instance size as needed
  engine                  = "mysql"
  engine_version          = "8.0"           # You can specify the version required
  db_name                 = local.secret_values["DB_NAME"]     # Replace with your desired database name
  username                = local.secret_values["DB_USER"]     # From the secret
  password                = local.secret_values["DB_PASSWORD"] # From the secret
  allocated_storage       = 20              # Adjust storage as needed
  storage_type            = "gp2"           # General Purpose SSD
  backup_retention_period = 7               # Number of days to retain backups
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]  # Associate the new security group
  db_subnet_group_name    = aws_db_subnet_group.mydb_subnet_group.name
  publicly_accessible     = false          # Ensure the DB is not publicly accessible
  storage_encrypted       = true
  skip_final_snapshot     = true
  tags = {
    Name = "WordPressDBInstance"
  }
}

output "db_endpoint" {
  value = aws_db_instance.mydb.endpoint
}
