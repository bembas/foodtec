# Generic
variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = ""
}

variable "account_prefix" {
  description = "The AWS account name prefix."
  type        = string
  default     = ""
}

variable "env" {
  description = "The AWS enviroment"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = ""
}

variable "workspace_name" {
  description = "The workspace name for the"
  type        = string
  default     = ""
}

# RDS 

variable "database_username" {
  type        = string
  description = "Username for the master DB user"
  sensitive   = true
  default     = "usroot"
}

variable "database_password" {
  type        = string
  description = "Password for the master DB user"
  sensitive   = true
  default     = ""
}
