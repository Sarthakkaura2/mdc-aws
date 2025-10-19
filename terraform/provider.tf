# -----------------------------------------------------------------------------
# 1. Terraform Block (Required Providers/Versions)
# Best practice is to put this in versions.tf, but it's okay here.
# -----------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # This forces the use of a modern version that supports the 'regions' argument
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# 2. Default Provider (Used by all resources without an explicit 'provider' argument)
# This is the FIX.
# -----------------------------------------------------------------------------
provider "aws" {
  # This will be the default provider instance
  region = var.aws_region 
}

# -----------------------------------------------------------------------------
# 3. Aliased Provider (Only needed if you deploy to a different account/region, 
#                     but okay to keep if you reference it later)
# -----------------------------------------------------------------------------
provider "aws" {
  alias  = "management"
  region = var.aws_region 
  # Note: If var.aws_region is the same for both the default and the alias,
  # the alias is redundant unless you use it to manage credentials/profile.
}
