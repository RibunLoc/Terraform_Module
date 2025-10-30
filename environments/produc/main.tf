provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Project     = "MyTerraformLab"
    Managed     = "Terraform"
    Environment = "Production"
  }
}


