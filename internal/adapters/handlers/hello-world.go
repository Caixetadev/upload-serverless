package handlers

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
)

type HelloWorldHandler struct{}

func NewHelloWorldHandler() *HelloWorldHandler {
	return &HelloWorldHandler{}
}

func (h *HelloWorldHandler) SayHello(
	ctx context.Context,
	req events.APIGatewayV2HTTPRequest,
) (events.APIGatewayV2HTTPResponse, error) {
	return events.APIGatewayV2HTTPResponse{Body: "Hello World!", StatusCode: 200}, nil
}
