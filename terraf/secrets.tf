

/* 8. 创建 Secrets Manager 密钥（用于 Email 凭证）
resource "aws_secretsmanager_secret" "email_credential_secret" {
  name       = "email-credentials"
  kms_key_id = aws_kms_key.kms_secrets.arn
  tags = {
    Name = "email-credential-secret"
  }
} */