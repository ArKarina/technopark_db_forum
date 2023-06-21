package repositories

import "technopark_db_forum/internal/models"

type VoteRepository interface {
	Vote(threadID int64, vote *models.Vote) (err error)
}
