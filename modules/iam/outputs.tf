output "role_arn" {
  description = "ARN of IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of IAM role"
  value       = aws_iam_role.this.name
}

output "policy_arn" {
  description = "ARN of IAM policy"
  value       = aws_iam_policy.this.arn
}

output "policy_name" {
  description = "Name of IAM policy"
  value       = aws_iam_policy.this.name
}