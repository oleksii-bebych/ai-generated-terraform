variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "A map of tags to add to IAM roles"
  type        = map(string)
  default     = {}
}