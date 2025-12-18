package middleware

import (
	"future-star-center-backend/internal/service"
	"net/http"
	"strings"

	"github.com/labstack/echo/v4"
)

// AuthMiddleware creates authentication middleware
func AuthMiddleware(authService service.AuthService) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			// Get session ID from header, cookie, or query parameter
			sessionID := getSessionID(c)
			if sessionID == "" {
				return c.JSON(http.StatusUnauthorized, map[string]string{
					"error":   "unauthorized",
					"message": "Missing session ID",
				})
			}

			// Validate session and get user
			user, err := authService.ValidateSession(c.Request().Context(), sessionID)
			if err != nil {
				return c.JSON(http.StatusUnauthorized, map[string]string{
					"error":   "unauthorized",
					"message": "Invalid session",
				})
			}

			// Set user and session ID in context
			c.Set("user", user)
			c.Set("session_id", sessionID)
			c.Set("user_id", user.ID.Hex())
			c.Set("user_role", string(user.Role))

			return next(c)
		}
	}
}

// OptionalAuthMiddleware creates optional authentication middleware
func OptionalAuthMiddleware(authService service.AuthService) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			sessionID := getSessionID(c)
			if sessionID != "" {
				user, err := authService.ValidateSession(c.Request().Context(), sessionID)
				if err == nil {
					c.Set("user", user)
					c.Set("session_id", sessionID)
					c.Set("user_id", user.ID.Hex())
					c.Set("user_role", string(user.Role))
				}
			}
			return next(c)
		}
	}
}

// RoleMiddleware creates role-based authorization middleware
func RoleMiddleware(allowedRoles ...string) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			userRole := c.Get("user_role")
			if userRole == nil {
				return c.JSON(http.StatusUnauthorized, map[string]string{
					"error":   "unauthorized",
					"message": "User not authenticated",
				})
			}

			role := userRole.(string)
			for _, allowedRole := range allowedRoles {
				if role == allowedRole {
					return next(c)
				}
			}

			return c.JSON(http.StatusForbidden, map[string]string{
				"error":   "forbidden",
				"message": "Insufficient permissions",
			})
		}
	}
}

// getSessionID extracts session ID from various sources
func getSessionID(c echo.Context) string {
	// 1. Check X-Session-ID header
	sessionID := c.Request().Header.Get("X-Session-ID")
	if sessionID != "" {
		return sessionID
	}

	// 2. Check Authorization header (Bearer token style)
	auth := c.Request().Header.Get("Authorization")
	if auth != "" && strings.HasPrefix(auth, "Bearer ") {
		return strings.TrimPrefix(auth, "Bearer ")
	}

	// 3. Check session_id cookie
	cookie, err := c.Cookie("session_id")
	if err == nil && cookie.Value != "" {
		return cookie.Value
	}

	// 4. Check query parameter
	return c.QueryParam("session_id")
}
