package usecases

import "technopark_db_forum/internal/models"

type PostUseCase interface {
	Get(postID int64, relatedData *[]string) (postFull *models.PostFull, err error)
	Update(post *models.Post) (err error)
}
