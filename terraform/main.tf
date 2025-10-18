locals {
stackset_name = "MDC-AWS-Org-Onboarding-${var.aws_organization_id}"
}


resource "aws_cloudformation_stack_set" "mdc_org" {
name = local.stackset_name
permission_model = "SERVICE_MANAGED"
capabilities = ["CAPABILITY_NAMED_IAM"]


template_body = file(var.template_path)


auto_deployment {
enabled = true
retain_stacks_on_account_removal = false
}


deployment_targets {
# target the whole org. You can list organisational_unit_ids if desired.
organizational_unit_ids = []
}


operation_preferences {
max_concurrent_count = 5
}


tags = {
ManagedBy = "Terraform"
Purpose = "MDC-AWS-Org-Onboarding"
}
}


# Optional: Waiter / null_resource to run Azure REST API to create connector after StackSet is created
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
