package handler

import (
	"future-star-center-backend/internal/service"
	"net/http"

	"github.com/go-playground/validator/v10"
	"github.com/labstack/echo/v4"
)

// AuthHandler handles authentication HTTP requests
type AuthHandler struct {
	authService service.AuthService
	validator   *validator.Validate
}

// NewAuthHandler creates a new authentication handler
func NewAuthHandler(authService service.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
		validator:   validator.New(),
	}
}

// ErrorResponse represents an error response
type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message,omitempty"`
}

// SuccessResponse represents a success response
type SuccessResponse struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// Register handles user registration
func (h *AuthHandler) Register(c echo.Context) error {
	var req service.RegisterRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "invalid_request",
			Message: "Invalid request body",
		})
	}

	if err := h.validator.Struct(req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "validation_error",
			Message: err.Error(),
		})
	}

	resp, err := h.authService.Register(c.Request().Context(), req)
	if err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "registration_failed",
			Message: err.Error(),
		})
	}

	return c.JSON(http.StatusCreated, SuccessResponse{
		Message: "User registered successfully",
		Data:    resp,
	})
}

// Login handles user login
func (h *AuthHandler) Login(c echo.Context) error {
	var req service.LoginRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "invalid_request",
			Message: "Invalid request body",
		})
	}

	if err := h.validator.Struct(req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "validation_error",
			Message: err.Error(),
		})
	}

	resp, err := h.authService.Login(c.Request().Context(), req)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{
			Error:   "login_failed",
			Message: err.Error(),
		})
	}

	return c.JSON(http.StatusOK, SuccessResponse{
		Message: "Login successful",
		Data:    resp,
	})
}

// Logout handles user logout
func (h *AuthHandler) Logout(c echo.Context) error {
	sessionID := c.Get("session_id")
	if sessionID == nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "invalid_session",
			Message: "No active session found",
		})
	}

	err := h.authService.Logout(c.Request().Context(), sessionID.(string))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error:   "logout_failed",
			Message: err.Error(),
		})
	}

	return c.JSON(http.StatusOK, SuccessResponse{
		Message: "Logout successful",
	})
}

// RequestPasswordReset handles password reset requests
func (h *AuthHandler) RequestPasswordReset(c echo.Context) error {
	var req struct {
		Email string `json:"email" validate:"required,email"`
	}

	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "invalid_request",
			Message: "Invalid request body",
		})
	}

	if err := h.validator.Struct(req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "validation_error",
			Message: err.Error(),
		})
	}

	err := h.authService.RequestPasswordReset(c.Request().Context(), req.Email)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error:   "request_failed",
			Message: err.Error(),
		})
	}

	return c.JSON(http.StatusOK, SuccessResponse{
		Message: "If the email exists, a password reset link has been sent",
	})
}

// ResetPassword handles password reset
func (h *AuthHandler) ResetPassword(c echo.Context) error {
	var req service.ResetPasswordRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "invalid_request",
			Message: "Invalid request body",
		})
	}

	if err := h.validator.Struct(req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "validation_error",
			Message: err.Error(),
		})
	}

	err := h.authService.ResetPassword(c.Request().Context(), req)
	if err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "reset_failed",
			Message: err.Error(),
		})
	}

	return c.JSON(http.StatusOK, SuccessResponse{
		Message: "Password reset successfully",
	})
}

// GetSession handles session retrieval
func (h *AuthHandler) GetSession(c echo.Context) error {
	sessionID := c.Get("session_id")
	if sessionID == nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "invalid_session",
			Message: "No active session found",
		})
	}

	session, err := h.authService.GetSession(c.Request().Context(), sessionID.(string))
	if err != nil {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{
			Error:   "session_invalid",
			Message: err.Error(),
		})
	}

	user, err := h.authService.ValidateSession(c.Request().Context(), sessionID.(string))
	if err != nil {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{
			Error:   "session_invalid",
			Message: err.Error(),
		})
	}

	return c.JSON(http.StatusOK, SuccessResponse{
		Message: "Session valid",
		Data: map[string]interface{}{
			"valid":   true,
			"session": session,
			"user":    service.ToUserResponse(user),
		},
	})
}
