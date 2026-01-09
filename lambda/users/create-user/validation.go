package main

import (
	"fmt"
	"regexp"
	"strings"
)

var (
	// Email regex pattern (RFC 5322 simplified)
	emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

	// Phone number regex (E.164 format)
	phoneRegex = regexp.MustCompile(`^\+[1-9]\d{1,14}$`)
)

// validatePasswordComplexity checks password complexity without lookahead regex
func validatePasswordComplexity(password string) bool {
	var (
		hasLower   = false
		hasUpper   = false
		hasDigit   = false
		hasSpecial = false
	)

	specialChars := "@$!%*?&"

	for _, char := range password {
		switch {
		case char >= 'a' && char <= 'z':
			hasLower = true
		case char >= 'A' && char <= 'Z':
			hasUpper = true
		case char >= '0' && char <= '9':
			hasDigit = true
		case strings.ContainsRune(specialChars, char):
			hasSpecial = true
		}
	}

	return hasLower && hasUpper && hasDigit && hasSpecial
}

// ValidationError represents a validation error
type ValidationError struct {
	Field   string
	Message string
}

func (e ValidationError) Error() string {
	return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

// ValidateCreateUserRequest validates the create user request according to BR-USERS-001 and BR-USERS-002
func ValidateCreateUserRequest(req CreateUserRequest) error {
	// Validate email (required)
	if strings.TrimSpace(req.Email) == "" {
		return ValidationError{Field: "email", Message: "email is required"}
	}

	if !emailRegex.MatchString(req.Email) {
		return ValidationError{Field: "email", Message: "invalid email format"}
	}

	// Validate password (required) - BR-USERS-002
	if strings.TrimSpace(req.Password) == "" {
		return ValidationError{Field: "password", Message: "password is required"}
	}

	if len(req.Password) < 8 {
		return ValidationError{Field: "password", Message: "password must be at least 8 characters"}
	}

	if !validatePasswordComplexity(req.Password) {
		return ValidationError{
			Field:   "password",
			Message: "password must contain uppercase, lowercase, number, and special character (@$!%*?&)",
		}
	}

	// Validate firstName (required)
	if strings.TrimSpace(req.FirstName) == "" {
		return ValidationError{Field: "firstName", Message: "firstName is required"}
	}

	if len(req.FirstName) > 50 {
		return ValidationError{Field: "firstName", Message: "firstName must be 50 characters or less"}
	}

	// Validate lastName (required)
	if strings.TrimSpace(req.LastName) == "" {
		return ValidationError{Field: "lastName", Message: "lastName is required"}
	}

	if len(req.LastName) > 50 {
		return ValidationError{Field: "lastName", Message: "lastName must be 50 characters or less"}
	}

	// Validate phoneNumber (optional)
	if req.PhoneNumber != "" && !phoneRegex.MatchString(req.PhoneNumber) {
		return ValidationError{Field: "phoneNumber", Message: "phoneNumber must be in E.164 format (e.g., +12025551234)"}
	}

	return nil
}
