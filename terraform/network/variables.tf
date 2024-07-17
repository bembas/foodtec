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
