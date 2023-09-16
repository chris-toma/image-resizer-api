package main

import (
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"math/rand"
	"strconv"
)

type MyRequest struct {
	Image string `json:"image"`
}

type MyResponse struct {
	Message string `json:"message"`
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	req := MyRequest{Image: "test"}
	// Specify your AWS credentials and region
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: "Failed to load AWS config", StatusCode: 405}, err
	}

	// Create a DynamoDB client
	svc := dynamodb.NewFromConfig(cfg)

	// Specify the DynamoDB table name
	tableName := "resizedImages"

	// Create the PutItem input
	input := &dynamodb.PutItemInput{
		TableName: aws.String(tableName),
		Item: map[string]types.AttributeValue{
			"pk":    &types.AttributeValueMemberS{Value: strconv.Itoa(rand.Int())},
			"sk":    &types.AttributeValueMemberS{Value: "test"},
			"image": &types.AttributeValueMemberS{Value: req.Image},
		},
	}

	// Put the item into the DynamoDB table
	_, err = svc.PutItem(ctx, input)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: "Failed to put item in DynamoDB", StatusCode: 405}, err
	}

	return events.APIGatewayProxyResponse{Body: "Item successfully added to DynamoDB", StatusCode: 200}, nil
}

func main() {
	lambda.Start(handler)
}
