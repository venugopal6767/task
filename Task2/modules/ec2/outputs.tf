output "private_instance_ids" {
  description = "List of EC2 instance IDs for private instances"
  value       = aws_instance.private[*].id  # Reference all created instances' IDs
}