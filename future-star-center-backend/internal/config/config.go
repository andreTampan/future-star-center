package config

import (
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

// Config holds all configuration values
type Config struct {
	Port     string
	Env      string
	MongoDB  MongoDBConfig
	Redis    RedisConfig
	JWT      JWTConfig
	Session  SessionConfig
	Password PasswordConfig
}

// MongoDBConfig holds MongoDB configuration
type MongoDBConfig struct {
	URI      string
	Database string
}

// RedisConfig holds Redis configuration
type RedisConfig struct {
	Addr     string
	Password string
	DB       int
}

// JWTConfig holds JWT configuration
type JWTConfig struct {
	Secret    string
	ExpiresIn time.Duration
}

// SessionConfig holds session configuration
type SessionConfig struct {
	ExpiresIn time.Duration
}

// PasswordConfig holds password reset configuration
type PasswordConfig struct {
	ResetExpiresIn time.Duration
}

// Load loads configuration from environment variables
func Load() (*Config, error) {
	// Load .env file if it exists
	if err := godotenv.Load(); err != nil && !os.IsNotExist(err) {
		return nil, fmt.Errorf("error loading .env file: %w", err)
	}

	config := &Config{
		Port: getEnv("PORT", "8080"),
		Env:  getEnv("ENV", "development"),
		MongoDB: MongoDBConfig{
			URI:      getEnv("MONGODB_URI", "mongodb://localhost:27017"),
			Database: getEnv("MONGODB_DATABASE", "future_star_center"),
		},
		Redis: RedisConfig{
			Addr:     getEnv("REDIS_ADDR", "localhost:6379"),
			Password: getEnv("REDIS_PASSWORD", ""),
			DB:       getEnvAsInt("REDIS_DB", 0),
		},
		JWT: JWTConfig{
			Secret:    getEnv("JWT_SECRET", "your-super-secret-jwt-key"),
			ExpiresIn: getEnvAsDuration("JWT_EXPIRES_IN", "24h"),
		},
		Session: SessionConfig{
			ExpiresIn: getEnvAsDuration("SESSION_EXPIRES_IN", "7200s"), // 2 hours
		},
		Password: PasswordConfig{
			ResetExpiresIn: getEnvAsDuration("PASSWORD_RESET_EXPIRES_IN", "3600s"), // 1 hour
		},
	}

	return config, nil
}

// getEnv gets an environment variable with a fallback value
func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

// getEnvAsInt gets an environment variable as integer with a fallback value
func getEnvAsInt(key string, fallback int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return fallback
}

// getEnvAsDuration gets an environment variable as duration with a fallback value
func getEnvAsDuration(key, fallback string) time.Duration {
	if value := os.Getenv(key); value != "" {
		if duration, err := time.ParseDuration(value); err == nil {
			return duration
		}
	}
	if duration, err := time.ParseDuration(fallback); err == nil {
		return duration
	}
	return time.Hour // default fallback
}
