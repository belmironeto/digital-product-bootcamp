terraform {
  backend "s3" {
    bucket = "jboss-state"
    key    = "infra-terraform.tfstate"
    region = "us-east-1"
  }
}