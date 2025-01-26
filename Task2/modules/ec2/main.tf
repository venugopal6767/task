resource "aws_instance" "private" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = element(var.private_subnets, count.index)
  key_name      = var.key_name
  count         = 2
  vpc_security_group_ids = [var.security_groups]
  user_data     = var.user_data # Pass user data from the root module

  tags = {
    Name = "${var.name}-private-${count.index}"
  }
}