locals {
  # 1. FIX: Define the full template path using path.module here.
  # This resolves the "Variables not allowed" error in the variable block.
  full_template_path = "${path.module}/${var.template_path}"
  stackset_name      = "MDC-AWS-Org-Onboarding-${var.aws_organization_id}"
}

resource "aws_cloudformation_stack_set" "mdc_org" {
  name             = local.stackset_name
  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_NAMED_IAM"]
  
  # Use the local value for the template path
  template_body    = file(local.full_template_path)

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  # 2. FIX: Corrected structure for deployment_targets block with SERVICE_MANAGED.
  # It takes attributes like organizational_unit_ids directly.
  # Assumes var.aws_organization_id is the AWS Organization Root ID (o-xxxx) 
  # or the desired Organizational Unit ID (ou-xxxx).
  deployment_targets {
    organizational_unit_ids = [var.aws_organization_id]
  }

  operation_preferences {
    max_concurrent_count = 5
  }

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "MDC-AWS-Org-Onboarding"
  }
}

resource "null_resource" "create_azure_connector" {
  provisioner "local-exec" {
    command = <<EOT
az rest --method put \
  --url "https://management.azure.com/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.azure_resource_group}/providers/Microsoft.Security/multiCloudConnectors/awsOrgConnector?api-version=2023-10-01-preview" \
  --body '{"location":"${var.connector_location}","properties":{"cloudName":"AWS","environmentType":"awsOrganization","hierarchyIdentifier":"${var.aws_organization_id}","authenticationDetails":{"authenticationType":"awsAssumeRole","roleArn":"${var.azure_management_role_arn}"}}}'
EOT
  }
  triggers = {
    stackset_id = aws_cloudformation_stack_set.mdc_org.id
  }
}
