package service

import (
	"context"
	"errors"
	"fmt"
	"future-star-center-backend/internal/config"
	"future-star-center-backend/internal/domain"
	"future-star-center-backend/internal/repository"
	"future-star-center-backend/pkg/utils"
	"time"

	"github.com/google/uuid"
)

type authService struct {
	userRepo    repository.UserRepository
	sessionRepo repository.SessionRepository
	config      *config.Config
}

// NewAuthService creates a new authentication service
func NewAuthService(
	userRepo repository.UserRepository,
	sessionRepo repository.SessionRepository,
	config *config.Config,
) AuthService {
	return &authService{
		userRepo:    userRepo,
		sessionRepo: sessionRepo,
		config:      config,
	}
}

func (s *authService) Register(ctx context.Context, req RegisterRequest) (*AuthResponse, error) {
	// Check if user already exists
	_, err := s.userRepo.GetByEmail(ctx, req.Email)
	if err == nil {
		return nil, errors.New("user with this email already exists")
	}

	// Validate role
	if !req.Role.IsValid() {
		return nil, errors.New("invalid role")
	}

	// Hash password
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	// Create user
	user := &domain.User{
		Email:     req.Email,
		Password:  hashedPassword,
		FirstName: req.FirstName,
		LastName:  req.LastName,
		Role:      req.Role,
	}

	err = s.userRepo.Create(ctx, user)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	// Generate JWT token
	token, err := utils.GenerateJWT(user, s.config.JWT.Secret, s.config.JWT.ExpiresIn)
	if err != nil {
		return nil, fmt.Errorf("failed to generate token: %w", err)
	}

	// Create session
	session := &domain.Session{
		ID:        uuid.New().String(),
		UserID:    user.ID.Hex(),
		Email:     user.Email,
		Role:      user.Role,
		CreatedAt: time.Now(),
		ExpiresAt: time.Now().Add(s.config.Session.ExpiresIn),
	}

	err = s.sessionRepo.Create(ctx, session)
	if err != nil {
		return nil, fmt.Errorf("failed to create session: %w", err)
	}

	return &AuthResponse{
		User:      ToUserResponse(user),
		Token:     token,
		SessionID: session.ID,
		ExpiresAt: session.ExpiresAt.Unix(),
	}, nil
}

func (s *authService) Login(ctx context.Context, req LoginRequest) (*AuthResponse, error) {
	// Get user by email
	user, err := s.userRepo.GetByEmail(ctx, req.Email)
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	// Check if user is active
	if !user.IsActive {
		return nil, errors.New("account is deactivated")
	}

	// Check password
	if !utils.CheckPassword(req.Password, user.Password) {
		return nil, errors.New("invalid email or password")
	}

	// Update last login
	err = s.userRepo.UpdateLastLogin(ctx, user.ID.Hex())
	if err != nil {
		// Log error but don't fail the login
		fmt.Printf("Failed to update last login for user %s: %v\n", user.ID.Hex(), err)
	}

	// Generate JWT token
	token, err := utils.GenerateJWT(user, s.config.JWT.Secret, s.config.JWT.ExpiresIn)
	if err != nil {
		return nil, fmt.Errorf("failed to generate token: %w", err)
	}

	// Create session
	session := &domain.Session{
		ID:        uuid.New().String(),
		UserID:    user.ID.Hex(),
		Email:     user.Email,
		Role:      user.Role,
		CreatedAt: time.Now(),
		ExpiresAt: time.Now().Add(s.config.Session.ExpiresIn),
	}

	err = s.sessionRepo.Create(ctx, session)
	if err != nil {
		return nil, fmt.Errorf("failed to create session: %w", err)
	}

	return &AuthResponse{
		User:      ToUserResponse(user),
		Token:     token,
		SessionID: session.ID,
		ExpiresAt: session.ExpiresAt.Unix(),
	}, nil
}

func (s *authService) Logout(ctx context.Context, sessionID string) error {
	return s.sessionRepo.Delete(ctx, sessionID)
}

func (s *authService) RequestPasswordReset(ctx context.Context, email string) error {
	// Check if user exists
	user, err := s.userRepo.GetByEmail(ctx, email)
	if err != nil {
		// Don't reveal if user exists or not
		return nil
	}

	// Generate reset token
	token, err := utils.GenerateRandomToken(32)
	if err != nil {
		return fmt.Errorf("failed to generate reset token: %w", err)
	}

	// Set token expiry
	expiry := time.Now().Add(s.config.Password.ResetExpiresIn).Unix()

	// Save token to database
	err = s.userRepo.SetPasswordResetToken(ctx, user.Email, token, expiry)
	if err != nil {
		return fmt.Errorf("failed to save reset token: %w", err)
	}

	// TODO: Send email with reset token
	// For now, we'll just log it (in production, implement email sending)
	fmt.Printf("Password reset token for %s: %s\n", email, token)

	return nil
}

func (s *authService) ResetPassword(ctx context.Context, req ResetPasswordRequest) error {
	// Get user by reset token
	user, err := s.userRepo.GetByPasswordResetToken(ctx, req.Token)
	if err != nil {
		return errors.New("invalid or expired reset token")
	}

	// Hash new password
	hashedPassword, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}

	// Update user password
	user.Password = hashedPassword
	err = s.userRepo.Update(ctx, user)
	if err != nil {
		return fmt.Errorf("failed to update password: %w", err)
	}

	// Clear reset token
	err = s.userRepo.ClearPasswordResetToken(ctx, user.ID.Hex())
	if err != nil {
		return fmt.Errorf("failed to clear reset token: %w", err)
	}

	// Delete all user sessions (force re-login)
	err = s.sessionRepo.DeleteAllUserSessions(ctx, user.ID.Hex())
	if err != nil {
		// Log error but don't fail the operation
		fmt.Printf("Failed to delete user sessions for %s: %v\n", user.ID.Hex(), err)
	}

	return nil
}

func (s *authService) GetSession(ctx context.Context, sessionID string) (*domain.Session, error) {
	return s.sessionRepo.Get(ctx, sessionID)
}

func (s *authService) ValidateSession(ctx context.Context, sessionID string) (*domain.User, error) {
	// Get session
	session, err := s.sessionRepo.Get(ctx, sessionID)
	if err != nil {
		return nil, err
	}

	// Get user
	user, err := s.userRepo.GetByID(ctx, session.UserID)
	if err != nil {
		return nil, err
	}

	// Check if user is still active
	if !user.IsActive {
		return nil, errors.New("user account is deactivated")
	}

	return user, nil
}
