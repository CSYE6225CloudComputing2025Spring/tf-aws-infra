data "aws_caller_identity" "current" {}

resource "random_id" "kms_rds_suffix" {
  byte_length = 4
}

resource "random_id" "kms_ec2_suffix" {
  byte_length = 4
}

resource "random_id" "kms_s3_suffix" {
  byte_length = 4
}

resource "random_id" "kms_secrets_suffix" {
  byte_length = 4
}

# 2. 创建 KMS Key（用于加密 Secrets Manager 的 RDS 密码）
resource "aws_kms_key" "kms_rds" {
  description             = "KMS key for encrypting RDS password in Secrets Manager"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "alias_kms_rds" {
  name          = "alias/kms-rds-${random_id.kms_rds_suffix.hex}"
  target_key_id = aws_kms_key.kms_rds.key_id
}

resource "aws_kms_key" "kms_ec2" {
  description             = "KMS key for encrypting EC2 EBS volumes"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # 允许密钥管理员管理密钥
      {
        Sid    = "Allow administration of the key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      # 允许Auto Scaling服务使用密钥
      {
        Sid    = "Allow service-linked role use of the key",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      # 允许创建grant
      {
        Sid    = "Allow attachment of persistent resources",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        Action = [
          "kms:CreateGrant"
        ],
        Resource = "*",
        Condition = {
          "Bool" = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "alias_kms_ec2" {
  name          = "alias/kms-ec2-${random_id.kms_ec2_suffix.hex}"
  target_key_id = aws_kms_key.kms_ec2.key_id
}


# 4. 创建 KMS Key（用于 S3 加密）
resource "aws_kms_key" "kms_s3" {
  description             = "KMS key for encrypting S3 buckets"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  multi_region            = true
}

resource "aws_kms_alias" "alias_kms_s3" {
  name          = "alias/kms-s3-${random_id.kms_s3_suffix.hex}"
  target_key_id = aws_kms_key.kms_s3.key_id
}

# 5. 创建 KMS Key（用于 Secrets Manager，包括 Email 凭证）
resource "aws_kms_key" "kms_secrets" {
  description             = "KMS key for encrypting Secrets Manager secrets like email credentials"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "alias_kms_secrets" {
  name          = "alias/kms-secrets-${random_id.kms_secrets_suffix.hex}"
  target_key_id = aws_kms_key.kms_secrets.key_id
}