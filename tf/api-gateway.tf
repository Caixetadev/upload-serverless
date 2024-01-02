resource "aws_api_gateway_rest_api" "example" {
  name        = "ServerlessExample"
  description = "Terraform Serverless Application Example"

  binary_media_types = ["*/*"]
}

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "upload" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "POST"  
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_upload" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_method.upload.resource_id
  http_method = aws_api_gateway_method.upload.http_method

  request_templates = {
    "application/json" = jsonencode({
      route = "$context.resourcePath"
    })
  }

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.handler.invoke_arn
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.lambda_upload",
  ]

  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "test"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/test/*"
}
