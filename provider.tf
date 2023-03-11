provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  required_version = ">= 1.0"

  # backend "s3" {
  #   bucket         = "bucket_name"
  #   key            = "terraform.tfstate"
  #   region         = "ap-northeast-2"
  #   dynamodb_table = "terraform_state"
  # }

  required_providers {
    aws = {
      version = "~> 4.5"
    }
  }
}
