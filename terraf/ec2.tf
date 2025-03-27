resource "aws_instance" "web" {
  ami                    = var.ami_id
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
              
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                  -a fetch-config \
                  -m ec2 \
                  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
                  -s
                  
              # start the applicaiton
              # 启动应用（带重试逻辑）
              for i in {1..5}; do
                sudo systemctl daemon-reload
                sudo systemctl enable csye6225
                sudo systemctl restart csye6225
                
                if systemctl is-active --quiet csye6225; then
                  echo "Application started successfully!"
                  break
                else
                  echo "Attempt $i: Failed to start application. Retrying in 10 seconds..."
                  sleep 10
                fi
              done
              
              # 如果仍然失败，记录错误
              if ! systemctl is-active --quiet csye6225; then
                echo "ERROR: Application failed to start after 5 attempts!"
                journalctl -u csye6225 -b --no-pager > /var/log/csye6225-startup-failure.log
                exit 1
              fi
              EOF
}
