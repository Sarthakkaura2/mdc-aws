variable "aws_region" {
  description = "AWS region for StackSet admin operations"
  type        = string
  default     = "us-east-1"
}

variable "template_path" {
  description = "Path to CloudFormation template to deploy"
  type        = string
  default     = "terraform/templates/aws-org-onboarding.yaml"
}

variable "aws_management_account_id" {
  description = "AWS management account id"
  type        = string
}

variable "aws_organization_id" {
  description = "AWS Organization ID (o-xxxx)"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure subscription id for connector creation"
  type        = string
}

variable "azure_resource_group" {
  description = "Azure RG for MDC connector"
  type        = string
}

variable "connector_location" {
  description = "Azure region for connector"
  type        = string
  default     = "centralus"
}

variable "defender_role_name" {
  description = "Name of MDC role in member accounts"
  type        = string
  default     = "DefenderForCloud-Connector-Role"
}

variable "azure_management_role_arn" {
  description = "Role ARN created in AWS management account"
  type        = string
}
