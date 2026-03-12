package user_handlers

import (
	"fmt"

	"__EGG_NAMESPACE__/db/repository"
	"__EGG_NAMESPACE__/models/handlers"
	"__EGG_NAMESPACE__/models/responses"
	"__EGG_NAMESPACE__/services"
	"github.com/golang-jwt/jwt/v5"
	"github.com/labstack/echo/v4"
)

type UpdateUserHandler struct {
	User  *repository.User
	Token *string
	ctx   echo.Context
	err   error
	code  int
	r     *services.Registrar
}

func NewUpdateUserHandler(ctx echo.Context, r *services.Registrar) *UpdateUserHandler {
	return &UpdateUserHandler{
		ctx:  ctx,
		err:  nil,
		code: 200,
		r:    r,
	}
}

func UpdateUserJsonHandler(ctx echo.Context, r *services.Registrar) error {
	return NewUpdateUserHandler(ctx, r).Handle().JSON()
}

func (h *UpdateUserHandler) Handle() handlers.IHandler {
	jwt_token := h.ctx.Get("user").(*jwt.Token)
	claims := jwt_token.Claims.(*services.CustomJwt)
	userId := claims.UserId
	err := h.r.AuthService.CheckToken(jwt_token.Raw)
	if err != nil {
		return handlers.Lock(h, 401, err)
	}
	request, err := h.r.ValidatorService.ValidateUpdateUserCredentialRequest(h.ctx)
	if err != nil {
		return handlers.Lock(h, 400, err)
	}
	if request.ID != userId {
		return handlers.Lock(h, 403, fmt.Errorf("user ID mismatch: cannot update another user's credentials"))
	}
	h.User, err = h.r.UserService.UpdateUserCredentials(request)
	if err != nil {
		return handlers.Lock(h, 500, err)
	}
	h.Token, err = h.r.AuthService.Update(*h.User)
	if err != nil {
		return handlers.Lock(h, 500, err)
	}

	return h
}

func (h *UpdateUserHandler) JSON() error {
	if h.Token == nil {
		h.Token = new(string)
	}
	if h.err != nil {
		return responses.NewLoginResponse().Fail(h.ctx, h.code, h.err)
	} else {
		return responses.NewLoginResponse().Successful(h.ctx, h.User, *h.Token)
	}

}

func (h *UpdateUserHandler) SetError(err error) handlers.IHandler {
	h.err = err
	return h
}

func (h *UpdateUserHandler) SetCode(code int) handlers.IHandler {
	h.code = code
	return h
}

func (h *UpdateUserHandler) Code() int {
	return h.code
}

func (h *UpdateUserHandler) Data() any {
	return struct {
		User  *repository.User
		Token *string
	}{
		User:  h.User,
		Token: h.Token,
	}
}

func (h *UpdateUserHandler) Error() error {
	return h.err
}
