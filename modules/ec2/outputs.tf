output "instance_ids" {
  value = aws_instance.private[*].id
}
