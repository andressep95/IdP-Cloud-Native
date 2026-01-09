package main

import (
	"context"
	"errors"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

// UserRepository handles DynamoDB operations for users
type UserRepository struct {
	client    *dynamodb.Client
	tableName string
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(client *dynamodb.Client, tableName string) *UserRepository {
	return &UserRepository{
		client:    client,
		tableName: tableName,
	}
}

// EmailExistsError indicates that the email already exists
var EmailExistsError = errors.New("email already exists")

// CheckEmailExists checks if an email already exists using the email-index GSI
// Implements BR-USERS-001: Email must be unique
func (r *UserRepository) CheckEmailExists(ctx context.Context, email string) (bool, error) {
	input := &dynamodb.QueryInput{
		TableName:              aws.String(r.tableName),
		IndexName:              aws.String("email-index"),
		KeyConditionExpression: aws.String("email = :email"),
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":email": &types.AttributeValueMemberS{Value: email},
		},
		Limit: aws.Int32(1), // We only need to know if at least one exists
	}

	result, err := r.client.Query(ctx, input)
	if err != nil {
		return false, fmt.Errorf("failed to check email existence: %w", err)
	}

	return result.Count > 0, nil
}

// CreateUser creates a new user in DynamoDB
func (r *UserRepository) CreateUser(ctx context.Context, user User) error {
	// Marshal the user struct to DynamoDB attribute values
	item, err := attributevalue.MarshalMap(user)
	if err != nil {
		return fmt.Errorf("failed to marshal user: %w", err)
	}

	// Use condition expression to ensure email doesn't exist (double-check for race conditions)
	input := &dynamodb.PutItemInput{
		TableName:           aws.String(r.tableName),
		Item:                item,
		ConditionExpression: aws.String("attribute_not_exists(email)"),
	}

	_, err = r.client.PutItem(ctx, input)
	if err != nil {
		var condFailed *types.ConditionalCheckFailedException
		if errors.As(err, &condFailed) {
			return EmailExistsError
		}
		return fmt.Errorf("failed to create user: %w", err)
	}

	return nil
}
