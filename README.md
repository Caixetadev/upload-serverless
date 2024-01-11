# ☁️ Serverless Image Upload: Golang & AWS Playground

This repository showcases a serverless application for uploading images to Amazon S3 using Golang. The project leverages Terraform for infrastructure as code and integrates with various AWS services:

## Technologies Used
- **Go (Golang)** Main project language
- **API Gateway** for handling HTTP requests
- **Lambda functions** for serverless compute
- **S3** for store the images
- **SQS** for message queuing
- **Dead Letter Queue (DLQ)** for handling failed messages
- **SES** for sending email notifications
- **SNS** for triggering events

## System Architecture
![Frame](https://github.com/Caixetadev/upload-serverless/assets/87894998/111fb0af-2193-4d60-b27f-24e776b01c2a)
