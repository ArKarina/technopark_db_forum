package usecases

import "technopark_db_forum/internal/models"

type ThreadUseCase interface {
	CreatePosts(slugOrID string, posts *models.Posts) (err error)
	Get(slugOrID string) (thread *models.Thread, err error)
	Update(slugOrID string, thread *models.Thread) (err error)
	GetPosts(slugOrID string, limit, since int, sort string, desc bool) (posts *models.Posts, err error)
	Vote(slugOrID string, vote *models.Vote) (thread *models.Thread, err error)
}
