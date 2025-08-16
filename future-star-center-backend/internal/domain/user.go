package domain

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// User represents a user in the system
type User struct {
	ID                  primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Email               string             `json:"email" bson:"email" validate:"required,email"`
	Password            string             `json:"-" bson:"password" validate:"required,min=8"`
	FirstName           string             `json:"first_name" bson:"first_name" validate:"required,min=2"`
	LastName            string             `json:"last_name" bson:"last_name" validate:"required,min=2"`
	Role                UserRole           `json:"role" bson:"role" validate:"required"`
	IsActive            bool               `json:"is_active" bson:"is_active"`
	EmailVerified       bool               `json:"email_verified" bson:"email_verified"`
	LastLogin           *time.Time         `json:"last_login" bson:"last_login"`
	PasswordResetToken  *string            `json:"-" bson:"password_reset_token"`
	PasswordResetExpiry *time.Time         `json:"-" bson:"password_reset_expiry"`
	CreatedAt           time.Time          `json:"created_at" bson:"created_at"`
	UpdatedAt           time.Time          `json:"updated_at" bson:"updated_at"`
}

// UserRole represents user roles in the system
type UserRole string

const (
	RoleAdmin     UserRole = "admin"
	RoleTherapist UserRole = "therapist"
	RoleStaff     UserRole = "staff"
)

// Session represents a user session stored in Redis
type Session struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Email     string    `json:"email"`
	Role      UserRole  `json:"role"`
	CreatedAt time.Time `json:"created_at"`
	ExpiresAt time.Time `json:"expires_at"`
}

// IsValid checks if the session is still valid
func (s *Session) IsValid() bool {
	return time.Now().Before(s.ExpiresAt)
}

// GetFullName returns the full name of the user
func (u *User) GetFullName() string {
	return u.FirstName + " " + u.LastName
}

// IsValidRole checks if the role is valid
func (r UserRole) IsValid() bool {
	switch r {
	case RoleAdmin, RoleTherapist, RoleStaff:
		return true
	}
	return false
}
