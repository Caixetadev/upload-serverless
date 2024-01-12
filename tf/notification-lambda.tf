data "archive_file" "notification_lambda" {
  type        = "zip"
  source_file = "../build/notification/bin/bootstrap"
  output_path = "../build/notification/bin/bootstrap.zip"
}

resource "aws_lambda_function" "notification_lambda" {
  filename         = data.archive_file.notification_lambda.output_path
  function_name    = "notification_lambda"
  handler          = "bootstrap"
  source_code_hash = base64sha256(data.archive_file.notification_lambda.output_path)
  runtime          = "go1.x"
  role             = aws_iam_role.iam_for_lambda.arn


  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.notification_lambda,
    aws_iam_role_policy_attachment.s3,
    aws_iam_role_policy_attachment.sqs,
    aws_iam_role_policy_attachment.ses
  ]
}

resource "aws_lambda_event_source_mapping" "consumer-sqs" {
  event_source_arn = aws_sqs_queue.notification_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.notification_lambda.arn

  depends_on = [
    aws_sqs_queue.notification_queue
  ]
}


