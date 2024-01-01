package main

import (
	"teste/internal/adapters/handlers"

	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	handler := handlers.NewHelloWorldHandler()

	lambda.Start(handler.SayHello)
}