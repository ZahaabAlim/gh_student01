provider "aws" {
 region = "us-east-1"
}
 
terraform {
  backend "s3" {
    bucket = "tfstate--file"
    key    = "terraform.tfstate"
    region = "us-east-1"
 
    dynamodb_table = "TfStatelock"
  }
}

 
resource "aws_dynamodb_table" "students" {
 name           = "students"
 billing_mode   = "PROVISIONED"
 read_capacity = 1
 write_capacity = 1
 hash_key       = "studentId"
 attribute {
   name = "studentId"
   type = "S"
 }
}
 
resource "aws_lambda_function" "add_student" {
    filename = "add_student.zip"
    function_name = "add_student"
    handler      = "add_student.lambda_handler"
    runtime      = "python3.8"
    memory_size = 128
    role = aws_iam_role.lambda.arn
    environment {
        variables = {
            DYNAMODB_TABLE = aws_dynamodb_table.students.name
        }
    }
}
 
resource "aws_lambda_function" "list_students" {
    filename = "list_students.zip"
    function_name = "list_students"
    handler      = "list_students.lambda_handler"
    runtime      = "python3.8"
    role = aws_iam_role.lambda.arn
    environment {
        variables = {
            DYNAMODB_TABLE = aws_dynamodb_table.students.name
        }
    }
}
 
resource "aws_iam_role" "lambda" {
 name = "lambda_execution_role"
 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
 
# Attach the DynamoDB policy
 inline_policy {
   name = "dynamodb_policy"
   policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": "dynamodb:*",
     "Resource": "*"
   }
 ]
}
EOF
 }
 
}
 
# resource "aws_iam_role_policy_attachment" "students" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#   role       = aws_iam_role.lambda.name
# }
 
# resource "aws_api_gateway_rest_api" "students_api" {
#  name        = "students_api"
#  description = "API for managing students"
# }
 
# resource "aws_api_gateway_resource" "add_student_resource" {
#  rest_api_id = aws_api_gateway_rest_api.students_api.id
#  parent_id   = aws_api_gateway_rest_api.students_api.root_resource_id
#  path_part   = "add_student"
# }
 
# resource "aws_api_gateway_resource" "list_students_resource" {
#  rest_api_id = aws_api_gateway_rest_api.students_api.id
#  parent_id   = aws_api_gateway_rest_api.students_api.root_resource_id
#  path_part   = "list_students"
# }
 
# resource "aws_api_gateway_method" "add_student_method" {
#  rest_api_id   = aws_api_gateway_rest_api.students_api.id
#  resource_id   = aws_api_gateway_resource.add_student_resource.id
#  http_method   = "POST"
#  authorization = "NONE"
# }
 
# resource "aws_api_gateway_method" "list_students_method" {
#  rest_api_id   = aws_api_gateway_rest_api.students_api.id
#  resource_id   = aws_api_gateway_resource.list_students_resource.id
#  http_method   = "GET"
#  authorization = "NONE"
# }
 
# resource "aws_api_gateway_integration" "add_student_integration" {
#  rest_api_id             = aws_api_gateway_rest_api.students_api.id
#  resource_id             = aws_api_gateway_resource.add_student_resource.id
#  http_method             = aws_api_gateway_method.add_student_method.http_method
#  integration_http_method = "POST"
#  type                    = "AWS_PROXY"
#  uri                     = aws_lambda_function.add_student.invoke_arn
# }
 
# resource "aws_api_gateway_integration" "list_students_integration" {
#  rest_api_id             = aws_api_gateway_rest_api.students_api.id
#  resource_id             = aws_api_gateway_resource.list_students_resource.id
#  http_method             = aws_api_gateway_method.list_students_method.http_method
#  integration_http_method = "GET"
#  type                    = "AWS_PROXY"
#  uri                     = aws_lambda_function.list_students.invoke_arn
# }
 
# resource "aws_lambda_permission" "add_student_permission" {
#  statement_id  = "AddStudentPermission"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.add_student.function_name
#  principal     = "apigateway.amazonaws.com"
#  //source_arn    = aws_api_gateway_rest_api.students_api.execution_arn
# }
 
# resource "aws_lambda_permission" "list_students_permission" {
#  statement_id  = "ListStudentsPermission"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.list_students.function_name
#  principal     = "apigateway.amazonaws.com"
#  //source_arn    = aws_api_gateway_rest_api.students_api.execution_arn
# }
 
# resource "aws_api_gateway_deployment" "students_api_deployment" {
#   depends_on = [
#    aws_api_gateway_integration.add_student_integration,
#    aws_api_gateway_integration.list_students_integration
#  ]
#  rest_api_id = aws_api_gateway_rest_api.students_api.id
# }
 
# resource "aws_api_gateway_stage" "example" {
#   deployment_id = aws_api_gateway_deployment.students_api_deployment.id
#   rest_api_id   = aws_api_gateway_rest_api.students_api.id
#   stage_name    = "example"
# }
 
# output "api_gateway_url" {
#  value = aws_api_gateway_deployment.students_api_deployment.invoke_url
# }
# Create an IAM role for the Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "new_lambda_role"
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

# Attach a policy to the IAM role to allow access to DynamoDB
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "students_api" {
  name        = "students_api"
  description = "A REST API for managing students"

}

# Create a deployment for the API Gateway REST API
resource "aws_api_gateway_deployment" "students_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.students_api.id
  stage_name  = "dev"
  depends_on  = [
    aws_api_gateway_integration.add_student,
    aws_api_gateway_integration.list_students
  ]
}

# Create a resource for the /students path
resource "aws_api_gateway_resource" "students" {
  rest_api_id = aws_api_gateway_rest_api.students_api.id
  parent_id   = aws_api_gateway_rest_api.students_api.root_resource_id
  path_part   = "students"
}

# Create a method for the POST /students path
resource "aws_api_gateway_method" "add_student" {
  rest_api_id   = aws_api_gateway_rest_api.students_api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

# Create an integration for the POST /students path
resource "aws_api_gateway_integration" "add_student" {
  rest_api_id = aws_api_gateway_rest_api.students_api.id
  resource_id = aws_api_gateway_method.add_student.resource_id
  http_method = aws_api_gateway_method.add_student.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_student.invoke_arn
}

# Create a method for the GET /students path
resource "aws_api_gateway_method" "list_students" {
  rest_api_id   = aws_api_gateway_rest_api.students_api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

# Create an integration for the GET /students path
resource "aws_api_gateway_integration" "list_students" {
  rest_api_id = aws_api_gateway_rest_api.students_api.id
  resource_id = aws_api_gateway_method.list_students.resource_id
  http_method = aws_api_gateway_method.list_students.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_students.invoke_arn
}

# Create a permission for the API Gateway to invoke the add_student Lambda function
resource "aws_lambda_permission" "add_student" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_student.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.students_api.execution_arn}/*/${aws_api_gateway_method.add_student.http_method}${aws_api_gateway_resource.students.path}"
}

# Create a permission for the API Gateway to invoke the list_students Lambda function
resource "aws_lambda_permission" "list_students" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_students.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.students_api.execution_arn}/*/${aws_api_gateway_method.list_students.http_method}${aws_api_gateway_resource.students.path}"
}

# Create an API key for the API Gateway
resource "aws_api_gateway_api_key" "students_api_key" {
  name = "students_api_key"
}

# Create a usage plan for the API Gateway
resource "aws_api_gateway_usage_plan" "students_api_usage_plan" {
  name        = "students_api_usage_plan"
  description = "A usage plan for the students API"
  api_stages {
    api_id = aws_api_gateway_rest_api.students_api.id
    stage  = aws_api_gateway_deployment.students_api_deployment.stage_name
  }
}

# Associate the API key with the usage plan
resource "aws_api_gateway_usage_plan_key" "students_api_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.students_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.students_api_usage_plan.id
}

