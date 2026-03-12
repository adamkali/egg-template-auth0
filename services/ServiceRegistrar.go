package services

import "__EGG_NAMESPACE__/cmd/configuration"

type Registrar struct {
	Config           *configuration.Configuration
	AuthService      IAuthService
	MinioService     IMinioService
	RedisService     IRedisService
	UserService      IUserService
	ValidatorService *ValidatorService
}
