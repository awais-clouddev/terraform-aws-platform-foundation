terraform {
  backend "s3" {
    bucket       = "terraform-aws-platform-foundation-state-132218943329"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}