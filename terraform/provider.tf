terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
  required_version = ">= 1.5"
}

provider "aws" {
  alias  = "management"
  region = var.aws_region
}
