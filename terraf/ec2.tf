resource "aws_instance" "web" {
  ami                    = "ami-0098f3a6af12907c2"
  instance_type          = "t2.small"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = aws_subnet.first_public.id
  vpc_security_group_ids = [aws_security_group.application_security_group.id]
  key_name               = var.key_name

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2" # General Purpose SSD GP2
    delete_on_termination = true  # Ensures EBS volume is deleted when EC2 is terminated
  }

  disable_api_termination = false # Protect against accidental termination: No

  tags = {
    Name = "Custom-AMI-EC2-Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              
              # store rds information in etc environment folder
              cat <<EOT >> /etc/environment
              DB_HOST="${aws_db_instance.rds.address}"
              DB_PORT="3306"
              DB_USER="root"
              DB_PASSWORD="${var.db_password}"
              DB_NAME="cloud_computing"
              AWS_REGION="${var.aws_region}"
              S3_BUCKET="${aws_s3_bucket.private_bucket.bucket}"
              EOT

              # apply variables
              source /etc/environment

              # start the applicaiton as a non-root user
              sudo -u csye6225 systemctl restart csye6225
              EOF
}