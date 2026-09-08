provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "terraform-aws-platform-foundation"
      Environment = "bootstrap"
      ManagedBy   = "Terraform"
      Owner       = "Awais"
    }
  }
}