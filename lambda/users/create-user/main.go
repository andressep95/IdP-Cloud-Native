package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

// AppConfig holds the application configuration
type AppConfig struct {
	UsersTableName         string `json:"users_table_name"`
	UserDirectoryTableName string `json:"user_directory_table_name"`
	LogLevel               string `json:"log_level"`
}

var (
	dynamoClient *dynamodb.Client
	repo         *UserRepository
	appConfig    AppConfig
)

func init() {
	ctx := context.Background()

	// Load AWS config
	cfg, err := config.LoadDefaultConfig(ctx,
		config.WithRegion(os.Getenv("AWS_REGION")),
	)
	if err != nil {
		panic(fmt.Sprintf("unable to load SDK config: %v", err))
	}

	// Load configuration from Secrets Manager
	appConfig, err = loadConfig(ctx, cfg)
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize DynamoDB client
	dynamoClient = dynamodb.NewFromConfig(cfg)

	// Initialize repository
	repo = NewUserRepository(
		dynamoClient,
		appConfig.UsersTableName,
		appConfig.UserDirectoryTableName,
	)

	log.Printf(
		"Lambda initialized - UsersTable: %s, UserDirectoryTable: %s, LogLevel: %s",
		appConfig.UsersTableName,
		appConfig.UserDirectoryTableName,
		appConfig.LogLevel,
	)

}

// loadConfig loads configuration from Secrets Manager
func loadConfig(ctx context.Context, cfg aws.Config) (AppConfig, error) {
	secretName := os.Getenv("SECRET_NAME")
	if secretName == "" {
		return AppConfig{}, fmt.Errorf("SECRET_NAME environment variable is required")
	}

	// Create Secrets Manager client
	secretsClient := secretsmanager.NewFromConfig(cfg)

	// Get secret value
	result, err := secretsClient.GetSecretValue(ctx, &secretsmanager.GetSecretValueInput{
		SecretId: &secretName,
	})
	if err != nil {
		return AppConfig{}, fmt.Errorf("failed to get secret %s: %w", secretName, err)
	}

	// Parse secret string
	var config AppConfig
	if err := json.Unmarshal([]byte(*result.SecretString), &config); err != nil {
		return AppConfig{}, fmt.Errorf("failed to parse secret: %w", err)
	}

	// Set defaults
	if config.LogLevel == "" {
		config.LogLevel = "INFO"
	}

	return config, nil
}

func main() {
	lambda.Start(handler)
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	logInfo("Received create user request")

	// Parse request body
	var req CreateUserRequest
	if err := json.Unmarshal([]byte(request.Body), &req); err != nil {
		logError("Failed to parse request body", err)
		return errorResponse(400, "ERR-COMMON-400", "Invalid request body", err.Error())
	}

	// Validate request - BR-USERS-002 (password complexity)
	if err := ValidateCreateUserRequest(req); err != nil {
		logError("Validation failed", err)
		var valErr ValidationError
		if errors.As(err, &valErr) {
			return errorResponse(400, "ERR-USERS-003", valErr.Message, valErr.Field)
		}
		return errorResponse(400, "ERR-USERS-003", "Validation failed", err.Error())
	}

	// Check if email already exists - BR-USERS-001 (email uniqueness)
	exists, err := repo.CheckEmailExists(ctx, req.Email)
	if err != nil {
		logError("Failed to check email existence", err)
		return errorResponse(500, "ERR-COMMON-500", "Internal server error", "")
	}

	if exists {
		logWarn("Email already exists: " + req.Email)
		return errorResponse(409, "ERR-USERS-001", "A user with this email already exists", "Email must be unique")
	}

	// Hash password using bcrypt with cost 12
	passwordHash, err := bcrypt.GenerateFromPassword([]byte(req.Password), 12)
	if err != nil {
		logError("Failed to hash password", err)
		return errorResponse(500, "ERR-COMMON-500", "Internal server error", "")
	}

	// Generate UUID v4 for userId
	userID := uuid.New().String()
	now := time.Now().UTC().Format(time.RFC3339)

	// Create user entity - BR-USERS-004 (status = pending_verification)
	user := User{
		UserID:       userID,
		Email:        req.Email,
		PasswordHash: string(passwordHash),
		FirstName:    req.FirstName,
		LastName:     req.LastName,
		PhoneNumber:  req.PhoneNumber,
		Status:       "pending_verification",
		EntityType:   "USER",
		Metadata:     req.Metadata,
		CreatedAt:    now,
		UpdatedAt:    now,
	}

	// Save to DynamoDB
	if err := repo.CreateUser(ctx, user); err != nil {
		if errors.Is(err, EmailExistsError) {
			// Race condition - another request created the user
			logWarn("Email already exists (race condition): " + req.Email)
			return errorResponse(409, "ERR-USERS-001", "A user with this email already exists", "Email must be unique")
		}
		logError("Failed to create user", err)
		return errorResponse(500, "ERR-COMMON-500", "Internal server error", "")
	}

	logInfo(fmt.Sprintf("User created successfully: %s (%s)", userID, req.Email))

	// Build response
	response := CreateUserResponse{
		UserID:    userID,
		Email:     user.Email,
		Status:    user.Status,
		CreatedAt: time.Now().UTC(),
		Links: Links{
			Self:   fmt.Sprintf("/api/v1/users/%s", userID),
			Verify: fmt.Sprintf("/api/v1/users/%s/verify", userID),
		},
	}

	responseBody, err := json.Marshal(response)
	if err != nil {
		logError("Failed to marshal response", err)
		return errorResponse(500, "ERR-COMMON-500", "Internal server error", "")
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 201,
		Headers: map[string]string{
			"Content-Type": "application/json",
			"Location":     response.Links.Self,
		},
		Body: string(responseBody),
	}, nil
}

// errorResponse creates a standardized error response
func errorResponse(statusCode int, code, message, details string) (events.APIGatewayProxyResponse, error) {
	errResp := ErrorResponse{
		Code:    code,
		Message: message,
		Details: details,
	}

	body, _ := json.Marshal(errResp)

	return events.APIGatewayProxyResponse{
		StatusCode: statusCode,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
		Body: string(body),
	}, nil
}

// Logging helpers
func logInfo(message string) {
	if appConfig.LogLevel == "INFO" || appConfig.LogLevel == "DEBUG" {
		log.Printf("[INFO] %s", message)
	}
}

func logWarn(message string) {
	log.Printf("[WARN] %s", message)
}

func logError(message string, err error) {
	log.Printf("[ERROR] %s: %v", message, err)
}
