package repository

import (
	"context"
	"future-star-center-backend/internal/domain"
)

// UserRepository defines the interface for user data access
type UserRepository interface {
	Create(ctx context.Context, user *domain.User) error
	GetByID(ctx context.Context, id string) (*domain.User, error)
	GetByEmail(ctx context.Context, email string) (*domain.User, error)
	Update(ctx context.Context, user *domain.User) error
	Delete(ctx context.Context, id string) error
	UpdateLastLogin(ctx context.Context, id string) error
	SetPasswordResetToken(ctx context.Context, email, token string, expiry int64) error
	GetByPasswordResetToken(ctx context.Context, token string) (*domain.User, error)
	ClearPasswordResetToken(ctx context.Context, id string) error
}

// SessionRepository defines the interface for session management
type SessionRepository interface {
	Create(ctx context.Context, session *domain.Session) error
	Get(ctx context.Context, sessionID string) (*domain.Session, error)
	Delete(ctx context.Context, sessionID string) error
	DeleteAllUserSessions(ctx context.Context, userID string) error
	Update(ctx context.Context, session *domain.Session) error
}
