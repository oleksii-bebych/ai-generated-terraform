variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "Assume role policy document in JSON format"
  type        = string
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "Policy created by Terraform"
}

variable "policy_document" {
  description = "Policy document in JSON format"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to IAM role"
  type        = map(string)
  default     = {}
}