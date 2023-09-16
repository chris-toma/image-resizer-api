package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"log"
)

func HandleRequest(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	//catName := request.QueryStringParameters["cat_name"]
	log.Println("test")
	response := events.APIGatewayProxyResponse{Body: "{\"caca\":\"caca\"}", StatusCode: 200}
	return response, nil
}

func main() {
	lambda.Start(HandleRequest)
}
