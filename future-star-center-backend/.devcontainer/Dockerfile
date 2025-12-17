# Use the official Go image as a base for development
FROM golang:alpine

# Install common tools and Delve debugger
RUN apk add --no-cache bash git curl build-base && \
    go install github.com/go-delve/delve/cmd/dlv@latest

# Set up work directory
WORKDIR /workspace

# Expose the debug port
EXPOSE 8080 40000

# Set default command (override in devcontainer.json)
CMD ["sleep", "infinity"]
