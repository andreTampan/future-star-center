package service

import (
	"context"
	"future-star-center-backend/internal/domain"
)

// AuthService defines the interface for authentication service
type AuthService interface {
	Register(ctx context.Context, req RegisterRequest) (*AuthResponse, error)
	Login(ctx context.Context, req LoginRequest) (*AuthResponse, error)
	Logout(ctx context.Context, sessionID string) error
	RequestPasswordReset(ctx context.Context, email string) error
	ResetPassword(ctx context.Context, req ResetPasswordRequest) error
	GetSession(ctx context.Context, sessionID string) (*domain.Session, error)
	ValidateSession(ctx context.Context, sessionID string) (*domain.User, error)
}

// RegisterRequest represents a user registration request
type RegisterRequest struct {
	Email     string          `json:"email" validate:"required,email"`
	Password  string          `json:"password" validate:"required,min=8"`
	FirstName string          `json:"first_name" validate:"required,min=2"`
	LastName  string          `json:"last_name" validate:"required,min=2"`
	Role      domain.UserRole `json:"role" validate:"required"`
}

// LoginRequest represents a user login request
type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

// ResetPasswordRequest represents a password reset request
type ResetPasswordRequest struct {
	Token       string `json:"token" validate:"required"`
	NewPassword string `json:"new_password" validate:"required,min=8"`
}

// AuthResponse represents an authentication response
type AuthResponse struct {
	User      *UserResponse `json:"user"`
	Token     string        `json:"token"`
	SessionID string        `json:"session_id"`
	ExpiresAt int64         `json:"expires_at"`
}

// UserResponse represents a user response (without sensitive data)
type UserResponse struct {
	ID            string          `json:"id"`
	Email         string          `json:"email"`
	FirstName     string          `json:"first_name"`
	LastName      string          `json:"last_name"`
	Role          domain.UserRole `json:"role"`
	IsActive      bool            `json:"is_active"`
	EmailVerified bool            `json:"email_verified"`
	CreatedAt     int64           `json:"created_at"`
}

// ToUserResponse converts a domain.User to UserResponse
func ToUserResponse(user *domain.User) *UserResponse {
	return &UserResponse{
		ID:            user.ID.Hex(),
		Email:         user.Email,
		FirstName:     user.FirstName,
		LastName:      user.LastName,
		Role:          user.Role,
		IsActive:      user.IsActive,
		EmailVerified: user.EmailVerified,
		CreatedAt:     user.CreatedAt.Unix(),
	}
}
