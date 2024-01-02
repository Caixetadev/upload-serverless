data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../build/notification/bin/bootstrap"
  output_path = "../build/notification/bin/bootstrap.zip"
}

resource "aws_lambda_function" "lambda_notification" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "lambda_notification"
  handler          = "bootstrap"
  source_code_hash = base64sha256(data.archive_file.lambda_zip.output_path)
  runtime          = "go1.x"
  role          =  aws_iam_role.iam_for_lambda.arn


  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.notification_lambda,
    aws_iam_role_policy_attachment.s3,
    aws_iam_role_policy_attachment.sqs
  ]
}

resource "aws_lambda_event_source_mapping" "consumer-sqs" {
  event_source_arn = aws_sqs_queue.sqs_test.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_notification.arn

  depends_on = [
    aws_sqs_queue.sqs_test
  ]
}


