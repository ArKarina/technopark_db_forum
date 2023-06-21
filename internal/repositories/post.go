package repositories

import "technopark_db_forum/internal/models"

type PostRepository interface {
	GetByID(id int64) (post *models.Post, err error)
	Update(post *models.Post) (err error)
}
