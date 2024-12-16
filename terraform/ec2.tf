resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  availability_zone = var.availability_zone  # Set the AZ dynamically
  tags = {
    Name = var.ec2_name
  }

  root_block_device {
    volume_size = var.volume_size
  }

  provisioner "local-exec" {
    command = "echo 'Instance provisioned: ${self.public_ip}'"
  }
}