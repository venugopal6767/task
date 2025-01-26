variable "allocated_storage" {
  description = "The allocated storage in GB"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "The instance type for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "engine" {
  description = "The database engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "8.0"
}

variable "identifier" {
  description = "The unique identifier for the RDS instance"
  type        = string
}

variable "username" {
  description = "The master username for the MySQL database"
  type        = string
}

variable "password" {
  description = "The password for the MySQL master user"
  type        = string
}

# variable "db_name" {
#   description = "The database name"
#   type        = string
# }

variable "multi_az" {
  description = "If the DB instance should be multi-AZ"
  type        = bool
  default     = false
}

variable "storage_type" {
  description = "The type of storage to use"
  type        = string
  default     = "gp2"
}

variable "backup_retention_period" {
  description = "The backup retention period in days"
  type        = number
  default     = 7
}
