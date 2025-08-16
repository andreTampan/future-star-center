package repository

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"future-star-center-backend/internal/domain"
	"time"

	"github.com/redis/go-redis/v9"
)

type redisSessionRepository struct {
	client *redis.Client
}

// NewRedisSessionRepository creates a new Redis session repository
func NewRedisSessionRepository(client *redis.Client) SessionRepository {
	return &redisSessionRepository{
		client: client,
	}
}

func (r *redisSessionRepository) Create(ctx context.Context, session *domain.Session) error {
	sessionData, err := json.Marshal(session)
	if err != nil {
		return err
	}

	sessionKey := fmt.Sprintf("session:%s", session.ID)
	userSessionKey := fmt.Sprintf("user_sessions:%s", session.UserID)

	// Set session data with expiration
	duration := time.Until(session.ExpiresAt)
	err = r.client.Set(ctx, sessionKey, sessionData, duration).Err()
	if err != nil {
		return err
	}

	// Add session ID to user's session set
	err = r.client.SAdd(ctx, userSessionKey, session.ID).Err()
	if err != nil {
		return err
	}

	// Set expiration for user sessions set
	err = r.client.Expire(ctx, userSessionKey, duration).Err()
	if err != nil {
		return err
	}

	return nil
}

func (r *redisSessionRepository) Get(ctx context.Context, sessionID string) (*domain.Session, error) {
	sessionKey := fmt.Sprintf("session:%s", sessionID)

	sessionData, err := r.client.Get(ctx, sessionKey).Result()
	if err != nil {
		if err == redis.Nil {
			return nil, errors.New("session not found")
		}
		return nil, err
	}

	var session domain.Session
	err = json.Unmarshal([]byte(sessionData), &session)
	if err != nil {
		return nil, err
	}

	// Check if session is still valid
	if !session.IsValid() {
		// Clean up expired session
		r.Delete(ctx, sessionID)
		return nil, errors.New("session expired")
	}

	return &session, nil
}

func (r *redisSessionRepository) Delete(ctx context.Context, sessionID string) error {
	sessionKey := fmt.Sprintf("session:%s", sessionID)

	// Get session to find user ID
	session, err := r.Get(ctx, sessionID)
	if err != nil {
		// If session doesn't exist, consider it deleted
		return nil
	}

	// Remove from user's session set
	userSessionKey := fmt.Sprintf("user_sessions:%s", session.UserID)
	r.client.SRem(ctx, userSessionKey, sessionID)

	// Delete the session
	return r.client.Del(ctx, sessionKey).Err()
}

func (r *redisSessionRepository) DeleteAllUserSessions(ctx context.Context, userID string) error {
	userSessionKey := fmt.Sprintf("user_sessions:%s", userID)

	// Get all session IDs for this user
	sessionIDs, err := r.client.SMembers(ctx, userSessionKey).Result()
	if err != nil {
		return err
	}

	// Delete each session
	for _, sessionID := range sessionIDs {
		sessionKey := fmt.Sprintf("session:%s", sessionID)
		r.client.Del(ctx, sessionKey)
	}

	// Delete the user sessions set
	return r.client.Del(ctx, userSessionKey).Err()
}

func (r *redisSessionRepository) Update(ctx context.Context, session *domain.Session) error {
	sessionData, err := json.Marshal(session)
	if err != nil {
		return err
	}

	sessionKey := fmt.Sprintf("session:%s", session.ID)
	duration := time.Until(session.ExpiresAt)

	return r.client.Set(ctx, sessionKey, sessionData, duration).Err()
}
