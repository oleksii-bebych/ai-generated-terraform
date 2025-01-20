output "api_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_arn" {
  description = "The ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.arn
}

output "api_execution_arn" {
  description = "The execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "invoke_url" {
  description = "The URL to invoke the API Gateway"
  value       = aws_api_gateway_deployment.deployment.invoke_url
}