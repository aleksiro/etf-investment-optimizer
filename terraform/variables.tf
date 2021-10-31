variable "project_name" {
  type        = string
  default     = "etf-optimizer"
  description = "Project name to be used within resource naming as prefix"
}

variable "environment" {
  type        = string
  description = "Environment name, needs to be dev, test or prod"
  /*validation {
      condition = contains(["dev", "test", "prod"], var.environment)
      error_message = "Environment must be 'dev', 'test' or 'prod'"
  }
  */
}

variable "default_location" {
  type        = string
  default     = "EUROPE-NORTH1"
  description = "Default location for creating resources"
}