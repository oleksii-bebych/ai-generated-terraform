variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
}

variable "lambda_role_arn" {
  description = "The ARN of the IAM role for the Lambda function"
  type        = string
}

variable "handler" {
  description = "The handler for the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to be applied to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}

variable "source_file" {
  description = "The directory containing the Lambda function code"
  type        = string
}

/*variable "output_path" {
  description = "The path to the zip file containing the Lambda function code"
  type        = string
}*/