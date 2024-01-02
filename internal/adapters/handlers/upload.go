package handlers

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
	"teste/internal/utils"
	"teste/pkg/typesystem"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go/aws"
)

type UploadFunctionHandler struct {
	s3Client  *s3.Client
	sqsClient *sqs.Client
}

func NewUploaderFunctionHandler(s3Client *s3.Client, sqsClient *sqs.Client) *UploadFunctionHandler {
	return &UploadFunctionHandler{
		s3Client:  s3Client,
		sqsClient: sqsClient,
	}
}

func (h *UploadFunctionHandler) Upload(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	b64data := req.Body[strings.IndexByte(req.Body, ',')+1:]

	data, err := base64.StdEncoding.DecodeString(b64data)
	if err != nil {
		fmt.Println("Erro ao copiar dados: ", err)
		return events.APIGatewayProxyResponse{}, err
	}

	key := utils.GenerateRandomString(10)

	params := &s3.PutObjectInput{
		Bucket:      aws.String(os.Getenv("BUCKET_NAME")),
		Key:         aws.String(key),
		Body:        bytes.NewReader(data),
		ContentType: aws.String("image/png"),
	}

	_, err = h.s3Client.PutObject(ctx, params)
	if err != nil {
		return typesystem.NewServerError(err)
	}

	response := typesystem.Response{
		Message:    "File uploaded successfully",
		StatusCode: http.StatusOK,
	}

	jsonResponse, err := json.Marshal(response)
	if err != nil {
		return typesystem.NewServerError(err)
	}

	if err != nil {
		return typesystem.NewServerError(err)
	}

	sendMessageToSQS(ctx, h.sqsClient, key)

	return events.APIGatewayProxyResponse{StatusCode: 200, Body: string(jsonResponse)}, nil
}

func sendMessageToSQS(ctx context.Context, sqsClient *sqs.Client, key string) {
	_, err := sqsClient.SendMessage(ctx, &sqs.SendMessageInput{
		MessageBody: aws.String("Uploaded image with key " + key),
		QueueUrl:    aws.String(os.Getenv("SQS_URL")),
	})

	if err != nil {
		fmt.Printf("Got an error sending message: %s", err)
	}
}
