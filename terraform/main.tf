

locals {
  # StackSet name composed of a prefix and the organization ID
  stackset_name      = "MDC-AWS-Orgsz3-Onboarding-${var.aws_organization_id}"
  
  # Path to your template file
  full_template_path = "templates/aws-org-onboarding.template"
}


# -----------------------------------------------------------------------------
# --- 1. aws_cloudformation_stack_set Resource (The definition) ---
# -----------------------------------------------------------------------------
resource "aws_cloudformation_stack_set" "mdc_org" {
  # Use the local variable for the name
  name             = local.stackset_name 
  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_NAMED_IAM"]
  
  # 🎯 FIX: Use the file() function to read the template's content into a string.
  # This resolves the 'Template format error: unsupported structure'
  template_body    = file(local.full_template_path)

  auto_deployment {
    enabled                    = true
    retain_stacks_on_account_removal = false
  }

  operation_preferences {
    max_concurrent_count = 5
  }

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "MDC-AWS-Org-Onboarding"
  }
}

# -----------------------------------------------------------------------------
# --- 2. aws_cloudformation_stack_set_instance Resource (The deployment) ---
# -----------------------------------------------------------------------------
resource "aws_cloudformation_stack_set_instance" "mdc_org_instance" {
  stack_set_name = aws_cloudformation_stack_set.mdc_org.name
  
  # This block correctly specifies the deployment targets for SERVICE_MANAGED
  deployment_targets {
    organizational_unit_ids = [var.aws_organization_id]
  } 
    region         = "eu-west-1"
  }

# -----------------------------------------------------------------------------
# --- 3. Azure Connector Resource (Triggers after deployment) ---
# -----------------------------------------------------------------------------
resource "null_resource" "create_azure_connector" {
  provisioner "local-exec" {
    command = <<EOT
export AWS_MGMT_ACCOUNT_ID="${var.aws_management_account_id}"
export AZURE_MGMT_ROLE_ARN="${var.azure_management_role_arn}"
export AWS_ORG_ID="${var.aws_organization_id}"
export STACKSET_ARN="${local.stack_set_admin_role_arn}"

az rest --method put \
  --url "https://management.azure.com/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.azure_resource_group}/providers/Microsoft.Security/securityConnectors/awsOrgConnector?api-version=2024-03-01-preview" \
  --body '
    {
      "location": "${var.connector_location}",
      "properties": {
        "cloudName": "AWS",
        "hierarchyIdentifier": "${AWS_ORG_ID}",
        "authenticationDetails": {
          "authenticationType": "awsAssumeRole",
          "roleArn": "${AZURE_MGMT_ROLE_ARN}"
        },
        "organizationalData": {
          "organizationMembershipType": "Master",
          "masterAccountId": "${AWS_MGMT_ACCOUNT_ID}",
          "stacksetArn": "${STACKSET_ARN}"
        },
        "offerings": [
          {
            "offeringType": "CspmMonitorAwsOrganization",
            "description": "CSPM for AWS Organization"
          },
          {
            "offeringType": "CspmMonitorAws",
            "description": "CSPM for all Member Accounts"
          }
        ]
      }
    }
'
EOT
  }
  
  # Trigger only after the StackSet Instance (deployment) is created
  triggers = {
    stackset_id = aws_cloudformation_stack_set_instance.mdc_org_instance.id
  }
}
