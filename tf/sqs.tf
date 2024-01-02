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
