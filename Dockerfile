# Build stage
FROM golang:1.22-alpine AS builder

ARG SERVICE_NAME

WORKDIR /app

# Copy dependency files
COPY go.mod ./
RUN go mod download

# Copy source code
COPY . .

# Build static binary for the specified service
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/service ./cmd/${SERVICE_NAME}

# Final stage
FROM alpine:3.22

WORKDIR /app

# Install CA certificates
RUN apk add --no-cache ca-certificates

# Create non-root user
RUN adduser -D -H appuser

# Copy binary from builder
COPY --from=builder /app/service ./service

EXPOSE 8081

USER appuser

CMD ["./service"]