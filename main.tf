# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a DynamoDB table to store the student data
resource "aws_dynamodb_table" "student_table" {
  name           = "student_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "student_id"
  range_key      = "class_id"

  attribute {
    name = "student_id"
    type = "S"
  }

  attribute {
    name = "class_id"
    type = "S"
  }

  attribute {
    name = "student_name"
    type = "S"
  }
}

# Create a Lambda function that can add 
resource "aws_lambda_function" "add_student" {
  function_name = "add_student"
  handler       = "add_student.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.student_lambda_role.arn
  filename      = "add_student.zip" # This is a zip file that contains the lambda_function.py code
}
# Create a Lambda function that can  list students
resource "aws_lambda_function" "list_students" {
  function_name = "list_students"
  handler       = "list_students.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.student_lambda_role.arn
  filename      = "list_students.zip" # This is a zip file that contains the lambda_function.py code
}


# Create an IAM role for the Lambda function
resource "aws_iam_role" "student_lambda_role" {
  name = "student_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach a policy to the IAM role that allows access to DynamoDB
resource "aws_iam_role_policy_attachment" "student_lambda_policy" {
  role       = aws_iam_role.student_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Create an API Gateway to expose the Lambda function as a REST endpoint
resource "aws_api_gateway_rest_api" "student_api" {
  name        = "student_api"
  description = "A REST API for adding and listing students"
}

# Create a resource for the /student path
resource "aws_api_gateway_resource" "student_resource" {
  rest_api_id = aws_api_gateway_rest_api.student_api.id
  parent_id   = aws_api_gateway_rest_api.student_api.root_resource_id
  path_part   = "student"
}

# Create a method for the GET request on the /student path
resource "aws_api_gateway_method" "student_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  resource_id   = aws_api_gateway_resource.student_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Create an integration for the GET method to invoke the Lambda function
resource "aws_api_gateway_integration" "student_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.student_api.id
  resource_id             = aws_api_gateway_resource.student_resource.id
  http_method             = aws_api_gateway_method.student_get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.student_lambda.invoke_arn
}

# Create a method for the POST request on the /student path
resource "aws_api_gateway_method" "student_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  resource_id   = aws_api_gateway_resource.student_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Create an integration for the POST method to invoke the Lambda function
resource "aws_api_gateway_integration" "student_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.student_api.id
  resource_id             = aws_api_gateway_resource.student_resource.id
  http_method             = aws_api_gateway_method.student_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.student_lambda.invoke_arn
}

# Create a deployment for the API Gateway
resource "aws_api_gateway_deployment" "student_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.student_get_integration,
    aws_api_gateway_integration.student_post_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.student_api.id
  stage_name  = "dev"
}

# Create an output for the API endpoint URL
output "student_api_url" {
  value = aws_api_gateway_deployment.student_api_deployment.invoke_url
}

