package models

import "time"

type Threads []Thread

type Thread struct {
	ID      int64     `json:"id"`
	Title   string    `json:"title"`
	Author  string    `json:"author"`
	Forum   string    `json:"forum"`
	Message string    `json:"message"`
	Votes   int32     `json:"votes"`
	Slug    string    `json:"slug"`
	Created time.Time `json:"created"`
}

type ThreadUpdate struct {
	Title   string `json:"title"`
	Message string `json:"message"`
}
