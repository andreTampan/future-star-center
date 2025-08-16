# Future Star Center - Authentication API

A robust authentication system for the Future Star Center child development clinic management system. Built with Go, Echo framework, MongoDB, and Redis following SOLID principles.

## 🏗️ Architecture

The application follows Clean Architecture and SOLID principles:

- **Domain Layer**: Contains business entities and rules (`internal/domain/`)
- **Repository Layer**: Abstracts data access (`internal/repository/`)
- **Service Layer**: Contains business logic (`internal/service/`)
- **Handler Layer**: HTTP request handlers (`internal/handler/`)
- **Middleware Layer**: Cross-cutting concerns (`internal/middleware/`)

## 🚀 Features

- User registration with role-based access (Admin, Therapist, Staff)
- Secure password hashing using bcrypt
- JWT token generation and validation
- Session management with Redis
- Password reset functionality
- Email uniqueness validation
- Graceful server shutdown
- Health check endpoint
- Comprehensive error handling
- CORS support

## 🛠️ Tech Stack

- **Language**: Go 1.21
- **Web Framework**: Echo v4
- **Database**: MongoDB
- **Session Store**: Redis
- **Authentication**: JWT + Session-based
- **Password Hashing**: bcrypt
- **Validation**: go-playground/validator

## 📁 Project Structure

```
future-star-center-backend/
├── internal/
│   ├── config/          # Configuration management
│   ├── domain/          # Business entities
│   ├── handler/         # HTTP handlers
│   ├── middleware/      # HTTP middleware
│   ├── repository/      # Data access layer
│   └── service/         # Business logic layer
├── pkg/
│   └── utils/           # Utility functions
├── main.go              # Application entry point
├── go.mod               # Go module file
├── .env                 # Environment configuration
└── test_api.sh         # API testing script
```

## 🔧 Setup & Installation

### Prerequisites

- Go 1.21+
- MongoDB running on localhost:27017
- Redis running on localhost:6379
- Docker (for MongoDB and Redis containers)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd future-star-center-backend
   ```

2. **Install dependencies:**
   ```bash
   go mod tidy
   ```

3. **Start MongoDB and Redis:**
   ```bash
   # MongoDB
   docker run -d --name mongodb -p 27017:27017 mongo:latest
   
   # Redis
   docker run -d --name redis -p 6379:6379 redis:latest
   ```

4. **Configure environment variables:**
   Copy `.env.example` to `.env` and update values as needed:
   ```bash
   cp .env.example .env
   ```

5. **Run the application:**
   ```bash
   go run main.go
   ```

The server will start on port 8080 by default.

## 📚 API Endpoints

### Health Check
```
GET /health
```

### Authentication Endpoints

#### Register User
```
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "first_name": "John",
  "last_name": "Doe",
  "role": "admin" // "admin", "therapist", or "staff"
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

#### Logout (Protected)
```
POST /api/auth/logout
X-Session-ID: <session_id>
```

#### Get Session Info (Protected)
```
GET /api/auth/session
X-Session-ID: <session_id>
```

#### Request Password Reset
```
POST /api/auth/request-password-reset
Content-Type: application/json

{
  "email": "user@example.com"
}
```

#### Reset Password
```
POST /api/auth/reset-password
Content-Type: application/json

{
  "token": "reset_token_from_email",
  "new_password": "NewSecurePass123!"
}
```

## 🔐 Authentication Methods

The API supports multiple authentication methods:

1. **Session ID in Header**: `X-Session-ID: <session_id>`
2. **Bearer Token**: `Authorization: Bearer <session_id>`
3. **Cookie**: `session_id=<session_id>`
4. **Query Parameter**: `?session_id=<session_id>`

## 🧪 Testing

Run the comprehensive API test suite:

```bash
chmod +x test_api.sh
./test_api.sh
```

## 🔒 Security Features

- **Password Hashing**: Uses bcrypt with salt
- **Session Management**: Redis-based with expiration
- **JWT Tokens**: Stateless authentication with expiration
- **Input Validation**: Comprehensive request validation
- **Role-Based Access**: Three user roles with different permissions
- **Password Reset**: Secure token-based password reset
- **CORS**: Configurable cross-origin resource sharing

## 🌍 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `8080` |
| `ENV` | Environment (development/production) | `development` |
| `MONGODB_URI` | MongoDB connection string | `mongodb://localhost:27017` |
| `MONGODB_DATABASE` | MongoDB database name | `future_star_center` |
| `REDIS_ADDR` | Redis address | `localhost:6379` |
| `REDIS_PASSWORD` | Redis password | `""` |
| `REDIS_DB` | Redis database number | `0` |
| `JWT_SECRET` | JWT signing secret | `your-super-secret-jwt-key` |
| `JWT_EXPIRES_IN` | JWT expiration duration | `24h` |
| `SESSION_EXPIRES_IN` | Session expiration duration | `7200s` |
| `PASSWORD_RESET_EXPIRES_IN` | Password reset token expiration | `3600s` |

## 👥 User Roles

- **Admin**: Full system access
- **Therapist**: Patient management and therapy session access
- **Staff**: Limited administrative functions

## 🚀 Production Deployment

1. **Security Considerations**:
   - Change default JWT secret
   - Use environment-specific configuration
   - Enable HTTPS
   - Set up proper logging
   - Configure rate limiting

2. **Database Setup**:
   - Set up MongoDB replica set
   - Configure Redis persistence
   - Implement backup strategies

3. **Monitoring**:
   - Add health check endpoints
   - Implement metrics collection
   - Set up error tracking

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions, please contact the development team or create an issue in the repository.

---

**Future Star Center** - Empowering children's development through technology.
