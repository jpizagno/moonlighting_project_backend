provider "aws" {
  version = "~> 5.9.0"
  access_key = "${var.access_key}"  # from variables.tf
  secret_key = "${var.secret_key}" # from variables.tf
  region     = "${var.region}"  # from variables.tf
}


###############
# DynamoDB
###############
resource "aws_dynamodb_table" "moonlighting-projects" {
  name           = "moonlighting-projects"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"
  range_key      = "project"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "project"
    type = "S"
  }

}

###############
# Lambda put_project
###############
resource "aws_lambda_function" "put_project" {
  filename      = "put_project.zip"
  function_name = "put_project"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "index.handler"

  source_code_hash = "${filebase64sha256("put_project.zip")}"
  runtime = "nodejs18.x"
}

###############
# Lambda get_projects
###############
resource "aws_lambda_function" "get_projects" {
  filename      = "get_projects.zip"
  function_name = "get_projects"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "index.handler"

  source_code_hash = "${filebase64sha256("get_projects.zip")}"
  runtime = "nodejs18.x"
}


###############
# IAM Role and Policy
###############
resource "aws_iam_role" "iam_for_lambda" {
    name = "moonlighting-dynamodb_write-role-jim-terraform"
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
}

resource "aws_iam_role_policy" "dynamodb-lambda-policy"{
  name = "moonlighting_dynamodb_lambda_policy"
  role = "${aws_iam_role.iam_for_lambda.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "${aws_dynamodb_table.moonlighting-projects.arn}"
    }
  ]
}
EOF
}


###############
# Gateway API
###############
resource "aws_api_gateway_rest_api" "moonlightingapi" {
  name        = "MoonlightAPI"
  description = "Terraform MoonlightAPI"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${aws_api_gateway_rest_api.moonlightingapi.id}"
  parent_id   = "${aws_api_gateway_rest_api.moonlightingapi.root_resource_id}"
  path_part   = "api"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = "${aws_api_gateway_rest_api.moonlightingapi.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "cors_post_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.moonlightingapi.id}"
    resource_id   = "${aws_api_gateway_resource.resource.id}"
    http_method   = "${aws_api_gateway_method.post.http_method}"
    status_code   = "200"
    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = "true",
    }
    depends_on = ["aws_api_gateway_method.post"]
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = "${aws_api_gateway_rest_api.moonlightingapi.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "cors_get_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.moonlightingapi.id}"
    resource_id   = "${aws_api_gateway_resource.resource.id}"
    http_method   = "${aws_api_gateway_method.get.http_method}"
    status_code   = "200"
    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = "true",
    }
    depends_on = ["aws_api_gateway_method.get"]
}

resource "aws_api_gateway_integration" "lambda_put_project" {
  rest_api_id = "${aws_api_gateway_rest_api.moonlightingapi.id}"
  resource_id = "${aws_api_gateway_method.post.resource_id}"
  http_method = "${aws_api_gateway_method.post.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.put_project.invoke_arn}"
}

resource "aws_api_gateway_integration" "lambda_get_projects" {
  rest_api_id = "${aws_api_gateway_rest_api.moonlightingapi.id}"
  resource_id = "${aws_api_gateway_method.get.resource_id}"
  http_method = "${aws_api_gateway_method.get.http_method}"

  integration_http_method = "POST" # Not a bug. this needs to be POST even for GET
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.get_projects.invoke_arn}"
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.lambda_put_project",
    "aws_api_gateway_integration.lambda_get_projects",
    "aws_api_gateway_method.post",
    "aws_api_gateway_method.get",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.moonlightingapi.id}"
  stage_name  = "moonlingprojectstage"
}

resource "aws_lambda_permission" "apigw_put_project" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.put_project.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.moonlightingapi.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_get_projects" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_projects.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.moonlightingapi.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}"
}
