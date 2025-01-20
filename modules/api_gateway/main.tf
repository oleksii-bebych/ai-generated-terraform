resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.api_name}-${var.environment}"
  description = var.api_description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = var.tags
}

# Create root-level resources
resource "aws_api_gateway_resource" "root_resource" {
  for_each    = { for k, v in var.resources : k => v if v.parent_id == "" }
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.key
}

# Create child resources
resource "aws_api_gateway_resource" "child_resource" {
  for_each    = { for k, v in var.resources : k => v if v.parent_id != "" }
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.root_resource[each.value.parent_id].id
  path_part   = each.key
}

# Combine root and child resources for easier referencing
locals {
  all_resources = merge(
    aws_api_gateway_resource.root_resource,
    aws_api_gateway_resource.child_resource
  )
}

resource "aws_api_gateway_method" "method" {
  for_each      = var.methods
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = local.all_resources[each.value.resource].id
  http_method   = each.value.http_method
  authorization = each.value.authorization
}

resource "aws_api_gateway_integration" "integration" {
  for_each                = var.methods
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = local.all_resources[each.value.resource].id
  http_method             = aws_api_gateway_method.method[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  for_each      = var.methods
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${each.value.http_method}${local.all_resources[each.value.resource].path}"
}