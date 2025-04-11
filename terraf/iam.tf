resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-rds-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name        = "ec2-s3-policy"
  description = "Allow EC2 to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
      Resource = "${aws_s3_bucket.private_bucket.arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# KMS EBS 访问策略
resource "aws_iam_policy" "kms_ebs_access" {
  name        = "ec2-kms-ebs-access"
  description = "Allow EC2 to use KMS for EBS encryption"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        Resource = aws_kms_key.kms_ec2.arn
      }
    ]
  })
}

# Secrets Manager 访问策略
resource "aws_iam_policy" "secrets_manager_access" {
  name        = "ec2-secrets-manager-access"
  description = "Allow EC2 to access Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = aws_secretsmanager_secret.rds_password_secret.arn
      }
    ]
  })
}

# 将KMS策略附加到角色
resource "aws_iam_role_policy_attachment" "attach_kms_ebs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.kms_ebs_access.arn
}

# 将Secrets Manager策略附加到角色
resource "aws_iam_role_policy_attachment" "attach_secrets_manager" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_manager_access.arn
}

resource "aws_iam_policy" "kms_secrets_access" {
  name        = "ec2-kms-secrets-access"
  description = "Allow EC2 to use KMS key for Secrets Manager decryption"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*"
        ],
        Resource = aws_kms_key.kms_secrets.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_kms_secrets" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.kms_secrets_access.arn
}
