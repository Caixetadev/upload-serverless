data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

variable "lambda_function_name" {
  default = "lambda-upload"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "handler" {
  type        = "zip"
  source_dir  = "../build/upload/bin/"
  output_path = "../build/upload/bin/bootstrap.zip"
}

resource "aws_lambda_function" "handler" {
  filename         = data.archive_file.handler.output_path
  function_name    = var.lambda_function_name
  handler          = "bootstrap"
  source_code_hash = base64sha256(data.archive_file.handler.output_path)
  runtime          = "go1.x"
  role          =  aws_iam_role.iam_for_lambda.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.handler_lambda,
    aws_iam_role_policy_attachment.s3
  ]
}

resource "aws_cloudwatch_log_group" "handler_lambda" {
  name = "/aws/lambda/${var.lambda_function_name}"
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = ["arn:aws:s3:::*"]
  }
}

resource "aws_iam_policy" "s3" {
  name        = "s3"
  path        = "/"
  description = "IAM policy for s3"
  policy      = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.s3.arn
}