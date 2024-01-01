package handlers

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/service/ses"
	"github.com/aws/aws-sdk-go-v2/service/ses/types"
	"github.com/aws/aws-sdk-go-v2/service/sqs"

	"github.com/aws/aws-sdk-go/aws"
)

type NotificationHandler struct {
	sqsClient *sqs.Client
	sesClient *ses.Client
}

func NewNotificationHandler(sqsClient *sqs.Client, sesClient *ses.Client) *NotificationHandler {
	return &NotificationHandler{
		sqsClient: sqsClient,
		sesClient: sesClient,
	}
}

func (h *NotificationHandler) HandleSQSMessage(ctx context.Context, event events.SQSEvent) error {
	for _, record := range event.Records {
		err := h.sendEmail(ctx, record.Body, "caixetadev@gmail.com")
		if err != nil {
			fmt.Printf("Error sending email: %s\n", err)
			continue
		}

		fmt.Printf("Email sent successfully to caixetadev@gmail.com\n")
	}

	return nil
}

func (h *NotificationHandler) sendEmail(ctx context.Context, body, recipient string) error {
	input := &ses.SendEmailInput{
		Destination: &types.Destination{
			ToAddresses: []string{recipient},
		},
		Message: &types.Message{
			Body: &types.Body{
				Html: &types.Content{
					Charset: aws.String("UTF-8"),
					Data:    aws.String(body),
				},
			},
			Subject: &types.Content{
				Charset: aws.String("UTF-8"),
				Data:    aws.String("Subject of the email"),
			},
		},
		Source: aws.String("sender@example.com"),
	}

	_, err := h.sesClient.SendEmail(ctx, input)
	return err
}
