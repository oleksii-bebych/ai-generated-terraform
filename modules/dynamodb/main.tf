resource "aws_dynamodb_table" "todos_table" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  tags = merge(
    var.tags,
    {
      Name = var.table_name
    }
  )
  point_in_time_recovery {
    enabled = true
  }
}

# Add a sample item
resource "aws_dynamodb_table_item" "example_item_1" {
  table_name = aws_dynamodb_table.todos_table.name
  hash_key   = aws_dynamodb_table.todos_table.hash_key

  item = jsonencode({
    (var.hash_key) = { S = "Welcome to re:Invent 2024!" }

  })
}