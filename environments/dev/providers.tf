provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Awais"
    }
  }
}