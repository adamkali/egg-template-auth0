package responses

import "github.com/labstack/echo/v4"

type StringsResponse struct {
	Data    []string `json:"data"`
	Success bool     `json:"success"`
	Message string   `json:"message"`
} // @Name StringsResponse

func NewStringsResponse() *StringsResponse {
	return &StringsResponse{Success: false, Message: ""}
}

func (StringsResponse *StringsResponse) Successful(ctx echo.Context, strings []string) error {
	StringsResponse.Data = strings
	StringsResponse.Success = true
	return ctx.JSON(200, StringsResponse)
}

func (StringsResponse *StringsResponse) Fail(ctx echo.Context, code int, err error) error {
	StringsResponse.Message = err.Error()
	return ctx.JSON(code, StringsResponse)
}

