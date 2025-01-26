# modules/secretsmanager/variables.tf

variable "db_password" {
  type        = string
  description = "The password for the MySQL database"
}

variable "db_user" {
  type        = string
  description = "The username for the MySQL database"
}

