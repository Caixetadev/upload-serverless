package main

import (
	"context"
	"fmt"
	"teste/internal/adapters/handlers"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

func main() {
	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		fmt.Printf("Error loading AWS config: %s\n", err)
		return
	}

	s3Client := s3.NewFromConfig(cfg)
	sqsClient := sqs.NewFromConfig(cfg)

	handler := handlers.NewUploaderFunctionHandler(s3Client, sqsClient)

	lambda.Start(handler.Upload)
}
