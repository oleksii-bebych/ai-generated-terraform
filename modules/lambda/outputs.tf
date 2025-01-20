output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.function.function_name
}

output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.function.arn
}

output "function_invoke_arn" {
  description = "The invoke ARN of the Lambda function"
  value       = aws_lambda_function.function.invoke_arn
}

output "function_version" {
  description = "The version of the Lambda function"
  value       = aws_lambda_function.function.version
}