resource "aws_launch_template" "webapp" {
  name          = "csye6225-asg-launch-template" # 启动模板
  image_id      = var.ami_id                     # 
  instance_type = "t2.small"                     # 

  key_name = var.key_name # SSH 

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name #  	SAME_AS_CURRENT_EC2_INSTANCE
  }

  network_interfaces {
    associate_public_ip_address = true                                               # AssociatePublicIpAddress 	True
    security_groups             = [aws_security_group.application_security_group.id] # Security Group 	WebAppSecurityGroup
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      encrypted             = true
      kms_key_id            = aws_kms_key.kms_ec2.arn
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash

              # 获取RDS密码从Secrets Manager
              RDS_PASSWORD=$(aws secretsmanager get-secret-value \
               --secret-id ${aws_secretsmanager_secret.rds_password_secret.id} \
               --query 'SecretString' --output text | jq -r '.password')

              
              # store rds information in etc environment folder
              cat <<EOT >> /etc/environment
              DB_HOST="${aws_db_instance.rds.address}"
              DB_PORT="${var.db_port}"
              DB_USER="${var.db_user}"
              DB_PASSWORD="$RDS_PASSWORD"
              DB_NAME="${var.db_name}"
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
  )
}
