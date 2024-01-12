resource "aws_api_gateway_rest_api" "api_gateway_deploy" {
  name        = "Serverlessapi_gateway_deploy"
  description = "Terraform Serverless Application api_gateway_deploy"

  binary_media_types = ["*/*"]
}

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_deploy.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_deploy.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "upload" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_deploy.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_upload" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_deploy.id
  resource_id = aws_api_gateway_method.upload.resource_id
  http_method = aws_api_gateway_method.upload.http_method

  request_templates = {
    "application/json" = jsonencode({
      route = "$context.resourcePath"
    })
  }

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.upload_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_gateway_deploy" {
  depends_on = [
    aws_api_gateway_integration.lambda_upload,
  ]

  stage_name = "upload_serverless"
  rest_api_id = aws_api_gateway_rest_api.api_gateway_deploy.id
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway_deploy.execution_arn}/upload_serverless/*"
}
