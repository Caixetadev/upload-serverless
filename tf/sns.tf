resource "aws_sns_topic" "sns_dlq_notification" {
  name = "sns_dlq_notification"
}

resource "aws_sns_topic_subscription" "dlq_email_subscription" {
  topic_arn = aws_sns_topic.sns_dlq_notification.arn
  protocol  = "email"
  endpoint  = var.email
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
    QueueName = aws_sqs_queue.notification_dlq.name
  }
  alarm_actions = [aws_sns_topic.sns_dlq_notification.arn]
  ok_actions    = [aws_sns_topic.sns_dlq_notification.arn]
}
