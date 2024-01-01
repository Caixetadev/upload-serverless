package typesystem

import (
	"net/http"

	"github.com/aws/aws-lambda-go/events"
)

type Response struct {
	StatusCode int    `json:"statusCode"`
	Message    string `json:"message"`
}

func NewServerError(err error) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusInternalServerError,
		Body:       err.Error(),
	}, nil
}

func NewClientError(message string, statusCode int) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		StatusCode: statusCode,
		Body:       message,
	}, nil
}
