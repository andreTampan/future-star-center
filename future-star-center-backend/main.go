package main

import (
	"context"
	"fmt"
	"future-star-center-backend/internal/config"
	"future-star-center-backend/internal/handler"
	"future-star-center-backend/internal/middleware"
	"future-star-center-backend/internal/repository"
	"future-star-center-backend/internal/service"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/labstack/echo/v4"
	echomiddleware "github.com/labstack/echo/v4/middleware"
	"github.com/redis/go-redis/v9"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Connect to MongoDB
	mongoClient, err := connectMongoDB(cfg.MongoDB.URI)
	if err != nil {
		log.Fatalf("Failed to connect to MongoDB: %v", err)
	}
	defer mongoClient.Disconnect(context.Background())

	// Connect to Redis
	redisClient := connectRedis(cfg.Redis)

	// Initialize database
	mongoDB := mongoClient.Database(cfg.MongoDB.Database)

	// Create indexes
	if err := createIndexes(mongoDB); err != nil {
		log.Fatalf("Failed to create indexes: %v", err)
	}

	// Initialize repositories
	userRepo := repository.NewMongoUserRepository(mongoDB)
	sessionRepo := repository.NewRedisSessionRepository(redisClient)

	// Initialize services
	authService := service.NewAuthService(userRepo, sessionRepo, cfg)

	// Initialize handlers
	authHandler := handler.NewAuthHandler(authService)

	// Initialize Echo
	e := echo.New()

	// Middleware
	e.Use(echomiddleware.Logger())
	e.Use(echomiddleware.Recover())
	e.Use(echomiddleware.CORS())

	// Health check endpoint
	e.GET("/health", func(c echo.Context) error {
		return c.JSON(http.StatusOK, map[string]string{
			"status":    "healthy",
			"timestamp": time.Now().Format(time.RFC3339),
		})
	})

	// API routes
	api := e.Group("/api")

	// Auth routes
	auth := api.Group("/auth")
	auth.POST("/register", authHandler.Register)
	auth.POST("/login", authHandler.Login)
	auth.POST("/request-password-reset", authHandler.RequestPasswordReset)
	auth.POST("/reset-password", authHandler.ResetPassword)

	// Protected auth routes
	authProtected := auth.Group("")
	authProtected.Use(middleware.AuthMiddleware(authService))
	authProtected.POST("/logout", authHandler.Logout)
	authProtected.GET("/session", authHandler.GetSession)

	// Start server
	go func() {
		if err := e.Start(":" + cfg.Port); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	log.Printf("Server started on port %s", cfg.Port)

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt)
	<-quit
	log.Println("Shutting down server...")

	// Graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := e.Shutdown(ctx); err != nil {
		log.Fatal(err)
	}
	log.Println("Server shutdown complete")
}

func connectMongoDB(uri string) (*mongo.Client, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(uri))
	if err != nil {
		return nil, err
	}

	// Test the connection
	err = client.Ping(ctx, nil)
	if err != nil {
		return nil, err
	}

	log.Println("Connected to MongoDB")
	return client, nil
}

func connectRedis(cfg config.RedisConfig) *redis.Client {
	client := redis.NewClient(&redis.Options{
		Addr:     cfg.Addr,
		Password: cfg.Password,
		DB:       cfg.DB,
	})

	// Test the connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	_, err := client.Ping(ctx).Result()
	if err != nil {
		log.Fatalf("Failed to connect to Redis: %v", err)
	}

	log.Println("Connected to Redis")
	return client
}

func createIndexes(db *mongo.Database) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	users := db.Collection("users")

	// Create unique index on email
	indexModel := mongo.IndexModel{
		Keys:    map[string]int{"email": 1},
		Options: options.Index().SetUnique(true),
	}

	_, err := users.Indexes().CreateOne(ctx, indexModel)
	if err != nil {
		return fmt.Errorf("failed to create email index: %w", err)
	}

	log.Println("Database indexes created successfully")
	return nil
}
