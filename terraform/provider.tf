terraform {
required_providers {
aws = { source = "hashicorp/aws" }
}
required_version = ">= 1.5"
}


provider "aws" {
alias = "management"
region = var.aws_region


# Authentication strategy: GitHub OIDC or environment credentials
# When running locally, set AWS_PROFILE or env creds. In CI we assume role via the workflow.
}
