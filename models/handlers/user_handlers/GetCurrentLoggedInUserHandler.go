package user_handlers

import (
	"__EGG_NAMESPACE__/db/repository"
	"__EGG_NAMESPACE__/models/handlers"
	"__EGG_NAMESPACE__/models/responses"
	"__EGG_NAMESPACE__/services"
	"github.com/golang-jwt/jwt/v5"
	"github.com/labstack/echo/v4"
)

type GetCurrentLoggedInUserHandler struct {
	ctx  echo.Context
	err  error
	code int
	r    *services.Registrar
	data *repository.User
}

func CurrentJsonHandler(ctx echo.Context, r *services.Registrar) error {
	return NewGetCurrentLoggedInUserHandler(ctx, r).Handle().JSON()
}

func NewGetCurrentLoggedInUserHandler(
	ctx echo.Context,
	Registrar *services.Registrar,
) *GetCurrentLoggedInUserHandler {
	return &GetCurrentLoggedInUserHandler{
		ctx:  ctx,
		err:  nil,
		code: 200,
		r:    Registrar,
	}
}

func (h *GetCurrentLoggedInUserHandler) Handle() handlers.IHandler {
	jwt_token := h.ctx.Get("user").(*jwt.Token)
	claims := jwt_token.Claims.(*services.CustomJwt)
	err := h.r.AuthService.CheckToken(jwt_token.Raw)
	if err != nil {
		return handlers.Lock(h, 401, err)
	}
	h.data, err = h.r.UserService.Get(claims.UserId)
	if err != nil {
		return handlers.Lock(h, 404, err)
	}
	return h
}

func (h *GetCurrentLoggedInUserHandler) JSON() error {
	if h.err != nil {
		return responses.NewUserResponse().Fail(h.ctx, h.code, h.err)
	}
	return responses.NewUserResponse().Successful(h.ctx, h.data)
}

func (h *GetCurrentLoggedInUserHandler) SetCode(code int) handlers.IHandler {
	h.code = code
	return h
}

func (h *GetCurrentLoggedInUserHandler) Code() int {
	return h.code
}

func (h *GetCurrentLoggedInUserHandler) Data() any {
	return h.data
}

func (h *GetCurrentLoggedInUserHandler) Error() error {
	return h.err
}
func (h *GetCurrentLoggedInUserHandler) SetError(err error) handlers.IHandler {
	h.err = err
	return h
}
