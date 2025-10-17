terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"              # or your mgmt region
  profile = "aws-management"        # credentials for mgmt account
}

variable "template_url" {
  description = "URL of MDC AWS Organization onboarding CloudFormation template"
  type        = string
}

# --- MDC Organization StackSet ---
resource "aws_cloudformation_stack_set" "mdc_org_stackset" {
  name             = "MDC-Org-Onboarding"
  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_NAMED_IAM"]

  template_url = var.template_url

  auto_deployment {
    enabled = true
    retain_stacks_on_account_removal = false
  }

  deployment_targets {
    organizational_unit_ids = ["ou-xxxx-yyyyy"] # or omit to target whole org
  }

  operation_preferences {
    max_concurrent_count = 3
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Owner = "Security"
    Purpose = "MDC Organization Onboarding"
  }
}
