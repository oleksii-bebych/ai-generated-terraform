data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_region" "this" {}

module "dynamodb" {
  source     = "../../modules/dynamodb"
  table_name = "TodosDB-${var.environment}"
  tags = {
    Environment = var.environment
    Project     = "TodoApp"
  }
}

module "add_todo_function" {
  source = "../../modules/lambda"

  function_name   = "add-todo-function"
  environment     = "dev"
  lambda_role_arn = module.lambda_exec_role.role_arn
  handler         = "main.handler"
  runtime         = "python3.9"
  source_file     = "../../application/python/lambda/add_todo.py"

  environment_variables = {
    ENV_VAR_1 = "value1"
    ENV_VAR_2 = "value2"
    DDB_TABLE = module.dynamodb.table_name
  }

  tags = {
    Project = "MyProject"
    Owner   = "MyTeam"
  }
}

module "delete_todo_function" {
  source = "../../modules/lambda"

  function_name   = "delete-todo-function"
  environment     = "dev"
  lambda_role_arn = module.lambda_exec_role.role_arn
  handler         = "main.handler"
  runtime         = "python3.9"
  source_file     = "../../application/python/lambda/delete_todo.py"

  environment_variables = {
    ENV_VAR_1 = "value1"
    ENV_VAR_2 = "value2"
    DDB_TABLE = module.dynamodb.table_name
  }

  tags = {
    Project = "MyProject"
    Owner   = "MyTeam"
  }
}

module "get_todo_function" {
  source = "../../modules/lambda"

  function_name   = "get-todo-function"
  environment     = "dev"
  lambda_role_arn = module.lambda_exec_role.role_arn
  handler         = "get_todo.lambda_handler"
  runtime         = "python3.9"
  source_file     = "../../application/python/lambda/get_todo.py"

  environment_variables = {
    ENV_VAR_1 = "value1"
    ENV_VAR_2 = "value2"
    DDB_TABLE = module.dynamodb.table_name
  }

  tags = {
    Project = "MyProject"
    Owner   = "MyTeam"
  }
}

module "get_todos_function" {
  source = "../../modules/lambda"

  function_name   = "get-todos-function"
  environment     = "dev"
  lambda_role_arn = module.lambda_exec_role.role_arn
  handler         = "get_todos.lambda_handler"
  runtime         = "python3.9"
  source_file     = "../../application/python/lambda/get_todos.py"

  environment_variables = {
    ENV_VAR_1 = "value1"
    ENV_VAR_2 = "value2"
    DDB_TABLE = module.dynamodb.table_name
  }

  tags = {
    Project = "MyProject"
    Owner   = "MyTeam"
  }
}

module "get_landing_function" {
  source = "../../modules/lambda"

  function_name   = "get-landing-function"
  environment     = "dev"
  lambda_role_arn = module.lambda_exec_role.role_arn
  handler         = "get_landing.lambda_handler"
  runtime         = "python3.9"
  source_file     = "../../application/python/lambda/get_landing.py"

  environment_variables = {
    ENV_VAR_1 = "value1"
    ENV_VAR_2 = "value2"
    DDB_TABLE = module.dynamodb.table_name
  }

  tags = {
    Project = "MyProject"
    Owner   = "MyTeam"
  }
}

module "lambda_exec_role" {
  source = "../../modules/iam"

  role_name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  policy_name        = "lambda-exec-policy"
  policy_description = "IAM policy for Lambda function"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = module.dynamodb.table_arn
      }
    ]
  })

  tags = var.tags
}

# You can create additional roles for different Lambda functions as needed
module "lambda_custom_role" {
  source = "../../modules/iam"

  role_name = "lambda-custom-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  policy_name        = "lambda-custom-policy"
  policy_description = "Custom IAM policy for specific Lambda function"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = var.tags
}

module "api_gateway" {
  source = "../../modules/api_gateway"

  api_name        = "my-api"
  api_description = "My API Gateway"
  environment     = "dev"
  
  resources = {
    "index" = {
      parent_id = ""
    },
    "todos" = {
      parent_id = ""
    },
    "todo_id" = {
      parent_id = "todos"
    }
  }

  methods = {
    "get_landing" = {
      resource            = "index"
      http_method         = "GET"
      authorization       = "NONE"
      lambda_function_name = module.get_landing_function.function_name
      lambda_invoke_arn   = module.get_landing_function.function_invoke_arn
    },
    "get_todos" = {
      resource            = "todos"
      http_method         = "GET"
      authorization       = "NONE"
      lambda_function_name = module.get_todos_function.function_name
      lambda_invoke_arn   = module.get_todos_function.function_invoke_arn
    },
    "post_todo" = {
      resource            = "todos"
      http_method         = "POST"
      authorization       = "NONE"
      lambda_function_name = module.add_todo_function.function_name
      lambda_invoke_arn   = module.add_todo_function.function_invoke_arn
    },
    "get_todo" = {
      resource            = "todo_id"
      http_method         = "GET"
      authorization       = "NONE"
      lambda_function_name = module.get_todo_function.function_name
      lambda_invoke_arn   = module.get_todo_function.function_invoke_arn
    }
  }

  tags = {
    Project = "MyProject"
    Owner   = "MyTeam"
  }
}

output "api_gateway_url" {
  value = module.api_gateway.invoke_url
}