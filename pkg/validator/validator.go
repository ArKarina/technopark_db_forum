package validator

import (
	"regexp"
	"technopark_db_forum/internal/models"
)

var (
	regLatinNumUnderline = regexp.MustCompile("[a-zA-Z0-9_]*")
	regEmail             = regexp.MustCompile(".+@.+")
)

func ValidateUserData(user *models.User, isUpdate bool) (isValid bool) {
	if !isUpdate && (len(user.Fullname) == 0 || len(user.Email) == 0) {
		return false
	}
	if !regLatinNumUnderline.MatchString(user.Fullname) {
		return false
	}
	if !regEmail.MatchString(user.Email) {
		return false
	}
	return true
}
