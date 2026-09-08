data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-aws-platform-foundation-state-${data.aws_caller_identity.current.account_id}"
}