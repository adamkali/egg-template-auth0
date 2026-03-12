package requests

import (
	"mime/multipart"

	"github.com/google/uuid"
)

type UploadUserBackgroundRequest struct {
	UserId uuid.UUID `json:"user_id" form:"user_id"`
	File *multipart.FileHeader `json:"file" form:"file"`
}

// GetFile returns the file or an error
// must defer r.GetFile().Close()
func (r *UploadUserBackgroundRequest) GetFile() (multipart.File, error) {
	return r.File.Open()
}
