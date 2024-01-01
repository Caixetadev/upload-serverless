terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws" 
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "bucket" {
  bucket = "upload-images-serverless-caixeta"
}

resource "aws_sqs_queue" "sqs_test" {
  name                      = "sqs_test"
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "sqs_test_dlq" {
  name = "sqs_test_dlq"
}

resource "aws_sqs_queue_redrive_policy" "sqs_test_redrive_policy" {
  queue_url = aws_sqs_queue.sqs_test.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_test_dlq.arn
    maxReceiveCount     = 4
  })

  depends_on = [
    aws_sqs_queue.sqs_test,
    aws_sqs_queue.sqs_test_dlq
  ]
}

resource "aws_sqs_queue_redrive_allow_policy" "sqs_test_dlq_redrive_allow_policy" {
  queue_url = aws_sqs_queue.sqs_test_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.sqs_test.arn]
  })

  depends_on = [
    aws_sqs_queue.sqs_test,
    aws_sqs_queue.sqs_test_dlq
  ]
}

resource "aws_sns_topic" "sns_dlq_notification" {
  name = "sns_dlq_notification"
}

resource "aws_sns_topic_subscription" "sns_test_subscription" {
  topic_arn = aws_sns_topic.sns_dlq_notification.arn
  protocol  = "email"
  endpoint  = "caixetacloud@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "dlq_new_message_alarm" {
  alarm_name          = "dlq_new_message_alarm"
  statistic           = "Sum"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  period              = 600
  evaluation_periods  = 2
  namespace           = "AWS/SQS"
  dimensions = {
    QueueName = aws_sqs_queue.sqs_test_dlq.name
  }
  alarm_actions = [aws_sns_topic.sns_dlq_notification.arn]
  ok_actions    = [aws_sns_topic.sns_dlq_notification.arn]
}

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
  role             = aws_iam_role.lambda_sqs_role.arn
}

#Add Lambda trigger from sqs
resource "aws_lambda_event_source_mapping" "consumer-sqs" {
  event_source_arn = aws_sqs_queue.sqs_test.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_notification.arn

  depends_on = [
    aws_sqs_queue.sqs_test
  ]
}

resource "aws_iam_role" "lambda_sqs_role" {
  name               = "lambda_sqs_role"
  assume_role_policy = jsonencode({
   Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambda_sqs_role.name
  count      = length(var.iam_policy_arn)
  policy_arn = var.iam_policy_arn[count.index]
  depends_on = [
    aws_iam_role.lambda_sqs_role
  ]
}
