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
	client             *dynamodb.Client
	usersTable         string
	userDirectoryTable string
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(client *dynamodb.Client, usersTable, userDirectoryTable string) *UserRepository {
	return &UserRepository{
		client:             client,
		usersTable:         usersTable,
		userDirectoryTable: userDirectoryTable,
	}
}

// EmailExistsError indicates that the email already exists
var EmailExistsError = errors.New("email already exists")

// CheckEmailExists checks if an email already exists using the email-index GSI
// Implements BR-USERS-001: Email must be unique
func (r *UserRepository) CheckEmailExists(ctx context.Context, email string) (bool, error) {
	input := &dynamodb.QueryInput{
		TableName:              aws.String(r.usersTable),
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
	// ---------- 1. Write Source of Truth ----------
	userItem, err := attributevalue.MarshalMap(user)
	if err != nil {
		return fmt.Errorf("failed to marshal user: %w", err)
	}

	_, err = r.client.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: aws.String(r.usersTable),
		Item:      userItem,
	})
	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}

	// ---------- 2. Write Materialized View ----------
	dirEntry := UserDirectoryEntry{
		DirectoryShard:  computeDirectoryShard(user.UserID),
		CreatedAtUserId: fmt.Sprintf("%s#%s", user.CreatedAt, user.UserID),
		UserID:          user.UserID,
		Email:           user.Email,
		Status:          user.Status,
		CreatedAt:       user.CreatedAt,
	}

	dirItem, err := attributevalue.MarshalMap(dirEntry)
	if err != nil {
		// Do NOT fail user creation
		return nil
	}

	_, err = r.client.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: aws.String(r.userDirectoryTable),
		Item:      dirItem,
	})
	if err != nil {
		// Log only — eventual consistency by design
		fmt.Printf("[WARN] Failed to write user directory entry for user %s: %v\n", user.UserID, err)
	}

	return nil
}

func computeDirectoryShard(userID string) string {
	// Simple deterministic sharding (hex-based)
	return fmt.Sprintf("USER#%02x", userID[len(userID)-1]%16)
}
