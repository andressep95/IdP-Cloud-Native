package main

import "time"

// CreateUserRequest represents the input for creating a user
type CreateUserRequest struct {
	Email       string                 `json:"email"`
	Password    string                 `json:"password"`
	FirstName   string                 `json:"firstName"`
	LastName    string                 `json:"lastName"`
	PhoneNumber string                 `json:"phoneNumber,omitempty"`
	Metadata    map[string]interface{} `json:"metadata,omitempty"`
}

// CreateUserResponse represents the output after creating a user
type CreateUserResponse struct {
	UserID    string    `json:"userId"`
	Email     string    `json:"email"`
	Status    string    `json:"status"`
	CreatedAt time.Time `json:"createdAt"`
	Links     Links     `json:"links"`
}

// Links represents HATEOAS links
type Links struct {
	Self   string `json:"self"`
	Verify string `json:"verify"`
}

// User represents the complete user entity stored in DynamoDB
type User struct {
	UserID       string                 `dynamodbav:"userId"`
	Email        string                 `dynamodbav:"email"`
	PasswordHash string                 `dynamodbav:"passwordHash"`
	FirstName    string                 `dynamodbav:"firstName"`
	LastName     string                 `dynamodbav:"lastName"`
	PhoneNumber  string                 `dynamodbav:"phoneNumber,omitempty"`
	Status       string                 `dynamodbav:"status"`
	EntityType   string                 `dynamodbav:"entityType"`
	Metadata     map[string]interface{} `dynamodbav:"metadata,omitempty"`
	CreatedAt    string                 `dynamodbav:"createdAt"`
	UpdatedAt    string                 `dynamodbav:"updatedAt"`
}

// ErrorResponse represents an error response
type ErrorResponse struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details string `json:"details,omitempty"`
}

type UserDirectoryEntry struct {
	DirectoryShard  string `dynamodbav:"directoryShard"`
	CreatedAtUserId string `dynamodbav:"createdAtUserId"`
	UserID          string `dynamodbav:"userId"`
	Email           string `dynamodbav:"email"`
	Status          string `dynamodbav:"status"`
	CreatedAt       string `dynamodbav:"createdAt"`
}
