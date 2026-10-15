data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  # checkov:skip=CKV2_AWS_62:State-change event notification delivery is outside this lab.
  # checkov:skip=CKV_AWS_18:S3 access-log collection is outside this lab; production access auditing requires a reviewed logging design.
  # checkov:skip=CKV_AWS_144:Cross-region state replication is outside this single-region lab; disaster recovery is not demonstrated.
  # checkov:skip=CKV2_AWS_61:State versions are retained without automatic expiration; retention must be reviewed before production use.
  # checkov:skip=CKV_AWS_145:Explicit SSE-S3 AES256 encryption is used; customer-managed KMS controls are outside this lab.

  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  bucket = "terraform-aws-platform-foundation-state-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "Terraform Remote State"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "require_https" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
