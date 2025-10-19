terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Set a modern version, such as the latest major version (v5.0 or later)
      version = "~> 5.0" 
    }
  }
}


provider "aws" {
  alias  = "management"
  region = var.aws_region
}
