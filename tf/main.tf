terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_ses_email_identity" "ses_caixeta" {
  email = "caixetacloud@gmail.com"
}
