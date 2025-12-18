# Build stage - using Alpine for minimal vulnerabilities
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Update packages to fix vulnerabilities and install essential build dependencies
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
    ca-certificates \
    git

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download && go mod verify

# Copy source code
COPY . .

# Build static binary with security flags
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main .

# Final stage - using scratch for absolute minimal image
FROM scratch

# Copy CA certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy the static binary
COPY --from=builder /app/main /main

# Copy .env file if needed
COPY --from=builder /app/.env /.env

# Expose port
EXPOSE 8080

# Run the binary (no shell, no OS - maximum security)
ENTRYPOINT ["/main"]
