provider "aws" {
  region = "eu-central-1"
}

resource "aws_lambda_function" "image_resize" {
  function_name    = "image_resize"
  handler          = "image_resize"
  runtime          = "go1.x"
  source_code_hash = filebase64sha256("${path.module}/zipped/image_resize.zip")
  filename         = "${path.module}/zipped/image_resize.zip"

  role = aws_iam_role.lambda_role.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda function"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "lambda:InvokeFunction"  # Add this line
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Define the REST API
resource "aws_api_gateway_rest_api" "image_resize_api" {
  name               = "image_resize_api"
  description        = "Example API"
  binary_media_types = ["multipart/form-data"]
}

# Define the root resource
resource "aws_api_gateway_resource" "resize" {
  rest_api_id = aws_api_gateway_rest_api.image_resize_api.id
  parent_id   = aws_api_gateway_rest_api.image_resize_api.root_resource_id
  path_part   = "resize"
}

# Define the HTTP method (POST)
resource "aws_api_gateway_method" "image_resize_post" {
  rest_api_id   = aws_api_gateway_rest_api.image_resize_api.id
  resource_id   = aws_api_gateway_resource.resize.id
  http_method   = "POST"
  authorization = "NONE"
}

# Define the Lambda integration
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.image_resize_api.id
  resource_id = aws_api_gateway_resource.resize.id
  http_method = aws_api_gateway_method.image_resize_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.image_resize.invoke_arn
}

# Create a deployment
resource "aws_api_gateway_deployment" "example" {
  depends_on = [aws_api_gateway_integration.lambda]
  rest_api_id = aws_api_gateway_rest_api.image_resize_api.id
  stage_name  = "dev"
}


# Output the API Gateway endpoint URL
output "api_gateway_url" {
  value = aws_api_gateway_deployment.example.invoke_url
}


resource "aws_lambda_permission" "api_gateway_trigger" {
  statement_id  = "AllowExampleApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_resize.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.image_resize_api.execution_arn}/*/*/*"
}





resource "aws_iam_policy" "dynamodb_policy" {
  name = "dynamodb_policy" # Change to a suitable policy name
  description = "Policy for DynamoDB access"

  # Define your DynamoDB permissions here
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "dynamodb:PutItem",
        Effect = "Allow",
        Resource = "arn:aws:dynamodb:eu-central-1:969564135590:table/resizedImages"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  policy_arn = aws_iam_policy.dynamodb_policy.arn
  role       = aws_iam_role.lambda_role.name
}


