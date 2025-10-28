variable "rg_name" {
  description = "Resource Group name"
  type        = string
  default     = "patientor-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "app_name" {
  description = "Globally unique App Service name (lowercase letters/numbers)"
  type        = string
}

variable "image_reference" {
  description = "Full public container ref"
  type        = string
  default     = "ghcr.io/chenxu2394/patientor@sha256:bce3a0d76278af7a13debce5105ac581d6eef220cb43b6d20dfb8889caf4ff5d"

  validation {
    condition     = var.image_reference == "ghcr.io/chenxu2394/patientor@sha256:bce3a0d76278af7a13debce5105ac581d6eef220cb43b6d20dfb8889caf4ff5d"
    error_message = "image_reference is pinned; do not change."
  }
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}