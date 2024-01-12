package main

import (
	"context"
	"fmt"

	"github.com/Caixetadev/upload/internal/adapters/handlers"
	appconfig "github.com/Caixetadev/upload/internal/config"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ses"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

func main() {
	appConfig := appconfig.NewConfig()
	sesEmail := appConfig.GetSesEmail()

	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		fmt.Printf("Error loading AWS config: %s\n", err)
		return
	}

	sqsClient := sqs.NewFromConfig(cfg)
	sesClient := ses.NewFromConfig(cfg)

	handler := handlers.NewNotificationHandler(sqsClient, sesClient, sesEmail)

	lambda.Start(handler.HandleSQSMessage)
}
