terraform {
  required_version = ">= 0.13"

  backend "s3" {
    bucket         = "sharely-terraform-state-bucket"
    key            = "environments/stg/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "sharely-terraform-up-and-running-locks"
    encrypt        = true
  }
}
