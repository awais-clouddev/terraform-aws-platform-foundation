provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "terraform-aws-platform-foundation"
      Environment = "dev"
      ManagedBy   = "Terraform"
      Owner       = "Awais"
    }
  }
}