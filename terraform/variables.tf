# -----------------------------------------------------------------
# Harrington Capital plc -- Terraform Variables
# Phase 1: Azure Infrastructure
# -----------------------------------------------------------------

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "uksouth"
}

variable "environment" {
  description = "Environment tag (prod or dev)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["prod", "dev"], var.environment)
    error_message = "Environment must be 'prod' or 'dev'."
  }
}

variable "project" {
  description = "Project identifier used in resource naming"
  type        = string
  default     = "harrington"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "hcadmin"
}

variable "admin_password" {
  description = "Admin password for Windows Server VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for Linux VMs"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "address_space" {
  description = "VNet address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_app" {
  description = "App subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_data" {
  description = "Data subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_mgmt" {
  description = "Management subnet CIDR"
  type        = string
  default     = "10.0.3.0/24"
}

variable "vm_size_windows" {
  description = "VM size for Windows Server (DC)"
  type        = string
  default     = "Standard_B2s"
}

variable "vm_size_linux" {
  description = "VM size for Linux VMs"
  type        = string
  default     = "Standard_B1s"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "harrington-infrastructure-operations"
    Environment = "prod"
    ManagedBy   = "Terraform"
    Owner       = "infrastructure-team"
    CostCentre  = "TECH-INFRA-001"
  }
}
