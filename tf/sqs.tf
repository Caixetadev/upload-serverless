resource "aws_sqs_queue" "notification_queue" {
  name                      = "notification_queue"
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "notification_dlq" {
  name = "notification_dlq"
}

resource "aws_sqs_queue_redrive_policy" "notification_queue_redrive_policy" {
  queue_url = aws_sqs_queue.notification_queue.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_dlq.arn
    maxReceiveCount     = 4
  })

  depends_on = [
    aws_sqs_queue.notification_queue,
    aws_sqs_queue.notification_dlq
  ]
}

resource "aws_sqs_queue_redrive_allow_policy" "notification_dlq_redrive_allow_policy" {
  queue_url = aws_sqs_queue.notification_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.notification_queue.arn]
  })

  depends_on = [
    aws_sqs_queue.notification_queue,
    aws_sqs_queue.notification_dlq
  ]
}
