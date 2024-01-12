variable "region" {
  description = "The aws region"
  type        = string
  default     = "eu-central-1"
}

variable "bucket_name" {
  type = string 
}

variable "email" {
  type = string
}
