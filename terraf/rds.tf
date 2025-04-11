resource "random_id" "rds_secret_suffix" {
  byte_length = 4
}

# 1. 使用 random_password 生成一个随机密码
resource "random_password" "rds_password" {
  length  = 16
  special = false # 不使用特殊字符
}

# 2. 创建 Secrets Manager 密钥（用于 RDS 密码）
resource "aws_secretsmanager_secret" "rds_password_secret" {
  name       = "rds-password-${random_id.rds_secret_suffix.hex}"
  kms_key_id = aws_kms_key.kms_secrets.arn
  tags = {
    Name = "rds-password-secret"
  }
}

# 3. 将随机生成的密码存储到 Secrets Manager
resource "aws_secretsmanager_secret_version" "rds_password_value" {
  secret_id     = aws_secretsmanager_secret.rds_password_secret.id
  secret_string = random_password.rds_password.result # 使用生成的随机密码
}

# 4. 确保 Secrets Manager 密钥已经创建后，再通过 data 资源获取 RDS 密码
data "aws_secretsmanager_secret" "rds_password" {
  name = aws_secretsmanager_secret.rds_password_secret.name # 引用创建的 Secrets Manager 密钥名称
}

# RDS Parameter Group
resource "aws_db_parameter_group" "db_params" {
  name   = "my-db-params"
  family = "mysql8.0"
}

# RDS Instance
resource "aws_db_instance" "rds" {
  identifier        = "csye6225"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = "root"
  password          = data.aws_secretsmanager_secret_version.rds_password_version.secret_string

  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]            # The Database security group is attached to this RDS instance.
  db_subnet_group_name   = aws_db_subnet_group.private_subnets.name # Use Private subnet for RDS instances
  parameter_group_name   = aws_db_parameter_group.db_params.name
  db_name                = "cloud_computing"
  skip_final_snapshot    = true

  storage_encrypted = true                    # 启用加密
  kms_key_id        = aws_kms_key.kms_rds.arn # 使用之前创建的 KMS 密钥进行加密
}

data "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id  = data.aws_secretsmanager_secret.rds_password.id
  depends_on = [aws_secretsmanager_secret_version.rds_password_value]
}

