package requests

import (
	"__EGG_NAMESPACE__/db/repository"
	"github.com/google/uuid"
)

type UpdateCredentialsRequest struct {
	ID          uuid.UUID `json:"id"`
	Username    string    `json:"username"`
	Email       string    `json:"email"`
	OldPassword string    `json:"oldPassword"`
	Password    string    `json:"password"`
} // @name UpdateCredentialsRequest

func (u UpdateCredentialsRequest) Into(a func(password string) (string, error)) (repository.UpdateUserCredentialsParams, error) {
	var hashedPassword string
	var hash string
	var err error
	if u.Password != "" {
		hashedPassword, err = a(u.Password)
		if err != nil {
			return repository.UpdateUserCredentialsParams{}, err
		}
	}
	
	if u.OldPassword != "" {
		hash, err = a(u.OldPassword)
		if err != nil {
			return repository.UpdateUserCredentialsParams{}, err
		}
	}


	return repository.UpdateUserCredentialsParams{
		Username:   u.Username,
		Email:      u.Email,
		BCryptHash: hashedPassword,
		BCryptHash_2: hash,
		ID:         u.ID,
	}, nil
}

