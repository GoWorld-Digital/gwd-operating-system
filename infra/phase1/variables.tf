# infra/phase1/variables.tf
# GoWorld.Digital (ATLASHUB DIGITAL LTD — UK #17379237)

variable "aws_region" {
  description = "AWS region for GWD Core Phase 1 infrastructure"
  type        = string
  default     = "us-east-2"
}

variable "project" {
  description = "Project prefix for all GWD resources"
  type        = string
  default     = "gwd-core"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Legal entity owner tag"
  type        = string
  default     = "ATLASHUB-DIGITAL-LTD"
}

variable "company_number" {
  description = "UK Companies House registration number"
  type        = string
  default     = "17379237"
}

variable "vpc_cidr" {
  description = "CIDR block for the GWD Core VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the GWD Core Docker host"
  type        = string
  default     = "t3.medium"
}

variable "ec2_key_pair_name" {
  description = "Name of the EC2 SSH Key Pair"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the GWD Core host"
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_managed_rds" {
  description = "Toggle managed RDS (false in Phase 1 — uses containerized pgvector)"
  type        = bool
  default     = false
}

variable "budget_alert_email" {
  description = "Email address for AWS Budgets cost alerts"
  type        = string
  default     = "ops@goworld.digital"
}

variable "tf_state_bucket" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
  default     = "gwd-core-terraform-state"
}

variable "tf_lock_table" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "gwd-core-terraform-locks"
}

variable "vault_sync_bucket" {
  description = "S3 bucket for GWD Knowledge Vault sync"
  type        = string
  default     = "gwd-vault-sync-prod"
}

variable "media_assets_bucket" {
  description = "S3 bucket for GWD Radar Tech & Media assets"
  type        = string
  default     = "gwd-media-assets-prod"
}
