output "table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.todos_table.name
}

output "table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.todos_table.arn
}

output "table_id" {
  description = "The ID of the DynamoDB table"
  value       = aws_dynamodb_table.todos_table.id
}