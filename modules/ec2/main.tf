resource "aws_instance" "private" {
  count         = 2
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = element(var.private_subnets, count.index)
  key_name      = var.key_name
  user_data     = file(var.user_data)

  tags = {
    Name = "${var.name}-private-instance-${count.index}"
  }
}
