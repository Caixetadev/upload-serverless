variable "region" {
  description = "The aws region"
  type        = string
  default     = "eu-central-1"
}

variable "iam_policy_arn" {
  description = "IAM Policy to be attached to role"
  type        = list(string)
}

variable "aws_region" {
    default = "us-east-1"
    description = "AWS Region to deploy to"
}
