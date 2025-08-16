.PHONY: build run test clean docker-build docker-run docker-stop help

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
BINARY_NAME=future-star-center-api

# Build the application
build:
	$(GOBUILD) -o $(BINARY_NAME) -v ./...

# Run the application
run:
	$(GOCMD) run main.go

# Test the application
test:
	$(GOTEST) -v ./...

# Clean build files
clean:
	$(GOCLEAN)
	rm -f $(BINARY_NAME)

# Download dependencies
deps:
	$(GOMOD) download
	$(GOMOD) tidy

# Run tests with coverage
test-coverage:
	$(GOTEST) -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out

# Format code
fmt:
	$(GOCMD) fmt ./...

# Lint code
lint:
	golangci-lint run

# Run API tests
test-api:
	chmod +x test_api.sh
	./test_api.sh

# Docker commands
docker-build:
	docker build -t future-star-center-api .

docker-run:
	docker-compose up -d

docker-stop:
	docker-compose down

docker-logs:
	docker-compose logs -f api

# Development setup
dev-setup: deps
	@echo "Installing development tools..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Production build
build-prod:
	CGO_ENABLED=0 GOOS=linux $(GOBUILD) -a -installsuffix cgo -o $(BINARY_NAME) .

# Start local services (MongoDB + Redis)
services-up:
	docker run -d --name mongodb -p 27017:27017 mongo:latest || true
	docker run -d --name redis -p 6379:6379 redis:latest || true

# Stop local services
services-down:
	docker stop mongodb redis || true
	docker rm mongodb redis || true

# Help
help:
	@echo "Available commands:"
	@echo "  build        - Build the application"
	@echo "  run          - Run the application"
	@echo "  test         - Run tests"
	@echo "  test-api     - Run API integration tests"
	@echo "  clean        - Clean build files"
	@echo "  deps         - Download dependencies"
	@echo "  fmt          - Format code"
	@echo "  lint         - Lint code"
	@echo "  docker-build - Build Docker image"
	@echo "  docker-run   - Run with Docker Compose"
	@echo "  docker-stop  - Stop Docker Compose"
	@echo "  services-up  - Start MongoDB and Redis containers"
	@echo "  services-down - Stop MongoDB and Redis containers"
	@echo "  help         - Show this help message"
