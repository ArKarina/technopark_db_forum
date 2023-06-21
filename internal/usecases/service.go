package usecases

import "technopark_db_forum/internal/models"

type ServiceUseCase interface {
	Clear() (err error)
	GetStatus() (status *models.Status, err error)
}
