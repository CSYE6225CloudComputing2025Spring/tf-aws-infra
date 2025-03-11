resource "aws_instance" "web" {
  ami           = "ami-0f63515408e5f7154"
  instance_type = "t2.small"
  subnet_id              = aws_subnet.first_public.id
  vpc_security_group_ids = [aws_security_group.application_security_group.id]
    key_name               = var.key_name

  root_block_device {
    volume_size           = 25   
    volume_type           = "gp2"  # General Purpose SSD GP2
    delete_on_termination = true  # Ensures EBS volume is deleted when EC2 is terminated
  }

  disable_api_termination = false  # Protect against accidental termination: No

  tags = {
    Name = "Custom-AMI-EC2-Instance"
  }
}