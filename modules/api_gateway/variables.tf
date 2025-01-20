variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "The description of the API Gateway"
  type        = string
  default     = "Managed by Terraform"
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
}

variable "endpoint_type" {
  description = "The endpoint type of the API Gateway"
  type        = string
  default     = "REGIONAL"
}

variable "stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
  default     = "v1"
}

variable "methods" {
  description = "Map of API Gateway methods"
  type = map(object({
    resource            = string
    http_method         = string
    authorization       = string
    lambda_function_name = string
    lambda_invoke_arn   = string
  }))
}

variable "tags" {
  description = "Tags to be applied to the API Gateway"
  type        = map(string)
  default     = {}
}

variable "resources" {
  description = "Map of API Gateway resources"
  type = map(object({
    parent_id = string
  }))
}