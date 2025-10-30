provider "aws" {
  region = var.region
}

locals {
  common_tag = {
    Project     = "MyTerraformLab"
    Managed     = "Terraform"
    Environment = "Staging"
  }
}

