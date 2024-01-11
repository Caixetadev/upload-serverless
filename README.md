# ☁️ Serverless Image Upload: Golang & AWS Playground

This repository showcases a serverless application for uploading images to Amazon S3 using Golang. The project leverages Terraform for infrastructure as code and integrates with various AWS services:

## Technologies Used
- **Go (Golang):** The primary programming language for the project.
- **Terraform:** Infrastructure as Code (IaC) tool used to provision AWS services.
- **AWS Services:**
  - **API Gateway:** Handles HTTP requests, serving as the entry point to the serverless architecture.
  - **Lambda Functions:** Enables serverless compute for efficient and scalable processing.
  - **Amazon S3:** Storage solution for securely storing and retrieving images.
  - **SQS (Simple Queue Service):** Message queuing for asynchronous communication between components.
  - **Dead Letter Queue (DLQ):** Safeguards against failed messages, ensuring robustness in message processing.
  - **SES (Simple Email Service):** Facilitates the sending of email notifications from the application.
  - **SNS (Simple Notification Service):** Powers event-driven architecture by triggering notifications and events.

## System Architecture
![Frame](https://github.com/Caixetadev/upload-serverless/assets/87894998/111fb0af-2193-4d60-b27f-24e776b01c2a)
