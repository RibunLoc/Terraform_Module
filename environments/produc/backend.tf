terraform {
  backend "s3" {
    bucket         = "s3.hothanhloc"
    key            = "env/product/terrafform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "DynamoDB-Terraform"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">=1.13.0"
}