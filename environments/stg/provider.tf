terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.13"
    }
  }
}

provider "aws" {
  profile     = "sharely"
  region      = "ap-northeast-1"
  max_retries = 20
  default_tags {
    tags = {
      Environment = "stg"
      Service     = "sharely"
    }
  }
}
