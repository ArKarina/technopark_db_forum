package repositories

import "technopark_db_forum/internal/models"

type ServiceRepository interface {
	Clear() (err error)
	GetStatus() (status *models.Status, err error)
}
