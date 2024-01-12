output "deployment_invoke_url" {
  description = "API Url of api gateway"
  value = aws_api_gateway_deployment.api_gateway_deploy.invoke_url
}
