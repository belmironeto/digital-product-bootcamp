terraform {
  backend "s3" {
    bucket = "gab-teste"
    key    = "infra-terraform.tfstate"
    region = "us-east-1"
  }
}