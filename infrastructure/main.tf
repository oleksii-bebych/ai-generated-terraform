provider "aws" {
  region = "us-west-2" # Replace with your desired region
}

data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_region" "this" {}

data "archive_file" "serverless_api_zip" {
  type             = "zip"
  source_dir       = "../application/python/lambda/"
  output_path      = "../application/lambda.zip"
  output_file_mode = "0666"
}

variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "lambda_zip_file" {
  description = "Path to the Lambda function zip file"
  default     = "lambda_function.zip"
}

resource "aws_dynamodb_table" "todos_table" {
  name         = "TodosDB"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_lambda_function" "get_todos" {
  filename         = data.archive_file.serverless_api_zip.output_path
  function_name    = "getTodos"
  role             = aws_iam_role.lambda_role.arn
  handler          = "get_todos.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.serverless_api_zip.output_base64sha256
  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.todos_table.name
    }
  }
}

resource "aws_lambda_function" "get_todo" {
  filename         = data.archive_file.serverless_api_zip.output_path
  function_name    = "getTodo"
  role             = aws_iam_role.lambda_role.arn
  handler          = "get_todo.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.serverless_api_zip.output_base64sha256

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.todos_table.name
    }
  }
}

resource "aws_lambda_function" "add_todo" {
  filename         = data.archive_file.serverless_api_zip.output_path
  function_name    = "addTodo"
  role             = aws_iam_role.lambda_role.arn
  handler          = "add_todo.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.serverless_api_zip.output_base64sha256

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.todos_table.name
    }
  }
}

resource "aws_lambda_permission" "api_gateway_invoke_add_todo" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todos_api.execution_arn}/*/*"
}

resource "aws_lambda_function" "delete_todo" {
  filename         = data.archive_file.serverless_api_zip.output_path
  function_name    = "deleteTodo"
  role             = aws_iam_role.lambda_role.arn
  handler          = "delete_todo.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.serverless_api_zip.output_base64sha256

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.todos_table.name
    }
  }
}

resource "aws_lambda_permission" "api_gateway_invoke_delete_todo" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todos_api.execution_arn}/*/*"
}

resource "aws_lambda_function" "update_todo" {
  filename         = data.archive_file.serverless_api_zip.output_path
  function_name    = "updateTodo"
  role             = aws_iam_role.lambda_role.arn
  handler          = "update_todo.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.serverless_api_zip.output_base64sha256

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.todos_table.name
    }
  }
}

resource "aws_lambda_permission" "api_gateway_invoke_update_todo" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todos_api.execution_arn}/*/*"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_permission" "api_gateway_invoke_get_todos" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_todos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todos_api.execution_arn}/*/*"
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda_dynamodb_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.todos_table.arn
      }
    ]
  })
}

resource "aws_api_gateway_rest_api" "todos_api" {
  name = "TodosAPI"
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.todos_api.id
  parent_id   = aws_api_gateway_rest_api.todos_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.todos_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "todos"
}

resource "aws_api_gateway_resource" "todo_id" {
  rest_api_id = aws_api_gateway_rest_api.todos_api.id
  parent_id   = aws_api_gateway_resource.todos.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "get_todos" {
  rest_api_id   = aws_api_gateway_rest_api.todos_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_todos" {
  rest_api_id = aws_api_gateway_rest_api.todos_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.get_todos.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_todos.invoke_arn
}

resource "aws_api_gateway_method" "post_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todos_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_todo" {
  rest_api_id = aws_api_gateway_rest_api.todos_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.post_todo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_todo.invoke_arn
}

resource "aws_api_gateway_method" "delete_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todos_api.id
  resource_id   = aws_api_gateway_resource.todo_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "delete_todo" {
  rest_api_id = aws_api_gateway_rest_api.todos_api.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.delete_todo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_todo.invoke_arn
}

resource "aws_api_gateway_deployment" "todos_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_todos,
    aws_api_gateway_integration.post_todo,
    aws_api_gateway_integration.delete_todo,
  ]

  rest_api_id = aws_api_gateway_rest_api.todos_api.id
  stage_name  = "prod"
}

resource "aws_api_gateway_account" "api_gateway_logs" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name              = "/aws/apigateway/${aws_api_gateway_rest_api.todos_api.name}"
  retention_in_days = 30
}

output "api_url" {
  value = aws_api_gateway_deployment.todos_api_deployment.invoke_url
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.todos_table.name
}

output "debug_path" {
  value = "${path.module}/application/python/lambda/add_todo.py"
}