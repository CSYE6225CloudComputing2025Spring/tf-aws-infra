resource "random_uuid" "s3_bucket_name" {}

resource "aws_s3_bucket" "private_bucket" {
  bucket        = random_uuid.s3_bucket_name.result
  force_destroy = true # Make sure Terraform can delete the bucket even if it is not empty.
}

# private S3 bucket
resource "aws_s3_bucket_public_access_block" "private_bucket-access" {
  bucket = aws_s3_bucket.private_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable default encryption for S3 Buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create a lifecycle policy for the bucket to transition objects 
# from STANDARD storage class to STANDARD_IA storage class after 30 days.
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.private_bucket.id
  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    filter {
      prefix = "" # apply to all objects in s3 bucket
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.private_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.kms_s3.arn
    }
  }
}