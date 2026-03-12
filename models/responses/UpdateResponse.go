package responses

import (
	"__EGG_NAMESPACE__/db/repository"
	"github.com/labstack/echo/v4"
)

type UpdateResponse struct {
	Data    *UserData `json:"data"`
	JWT     string   `json:"jwt"`
	Success bool     `json:"success"`
	Message string   `json:"message"`
} // @name UpdateUserResponse

func NewUpdateResponse() *UpdateResponse {
	return &UpdateResponse{ Success: false, Message: "" }
}

func (u *UpdateResponse) Successful(ctx echo.Context, data *repository.User, token string) {
	u.Data = UserDataFromRepository(data) 
	u.Success = true
	u.Message = "OK"
}

func (u *UpdateResponse) Fail(ctx echo.Context, code int, err error) {
	u.Success = false
	u.Message = err.Error()
}

