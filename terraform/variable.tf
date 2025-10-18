variable "aws_region" {
description = "AWS region for StackSet admin operations"
type = string
default = "us-east-1"
}


variable "template_path" {
description = "Local path to the CloudFormation template to deploy (StackSet)"
type = string
default = "${path.module}/templates/aws-org-onboarding.yaml"
}


variable "aws_management_account_id" {
description = "AWS management account id where StackSet is created"
type = string
}


variable "aws_organization_id" {
description = "AWS Organization ID (o-xxxx)"
type = string
}


variable "azure_subscription_id" {
description = "Azure subscription id used for creating the MDC connector"
type = string
}


variable "azure_resource_group" {
description = "Resource group where the multi-cloud connector resource will live"
type = string
}


variable "connector_location" {
description = "Azure location for the connector resource"
type = string
default = "centralus"
}


variable "defender_role_name" {
description = "Role name created in member account for MDC to assume"
type = string
default = "DefenderForCloud-Connector-Role"
}


variable "azure_management_role_arn" {
description = "ARN of role created in management account that MDC will reference (used in connector body)"
type = string
}
