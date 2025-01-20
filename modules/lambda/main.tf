resource "aws_lambda_function" "function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.function_name}-${var.environment}"
  role             = var.lambda_role_arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = var.environment_variables
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.function_name}-${var.environment}"
    }
  )
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.function.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "/aws/lambda/${aws_lambda_function.function.function_name}"
    }
  )
}