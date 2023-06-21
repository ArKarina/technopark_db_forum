package main

import (
	"fmt"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx"
	"technopark_db_forum/internal/handlers"
	"technopark_db_forum/internal/repositories/stores"
	"technopark_db_forum/internal/usecases/impl"
)

func main() {
	gin.SetMode(gin.ReleaseMode)
	router := gin.New()

	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"http://127.0.0.1:5000"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowCredentials = true

	conn, err := pgx.ParseConnectionString(fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable", "127.0.0.1", "dbforum", "dbforum", "dbforum", "5432"))

	db, err := pgx.NewConnPool(pgx.ConnPoolConfig{
		ConnConfig:     conn,
		MaxConnections: 100,
		AfterConnect:   nil,
		AcquireTimeout: 0,
	})

	defer db.Close()

	// Repositories
	userRepo := stores.CreateUserRepository(db)
	forumRepo := stores.CreateForumRepository(db)
	postRepo := stores.CreatePostRepository(db)
	serviceRepo := stores.CreateServiceRepository(db)
	threadRepo := stores.CreateThreadRepository(db)
	voteRepo := stores.CreateVoteRepository(db)

	// UseCases
	userUseCase := impl.CreateUserUseCase(userRepo)
	forumUseCase := impl.CreateForumUseCase(forumRepo, threadRepo, userRepo)
	postUseCase := impl.CreatePostUseCase(postRepo, userRepo, threadRepo, forumRepo)
	serviceUseCase := impl.CreateServiceUseCase(serviceRepo)
	threadUseCase := impl.CreateThreadUseCase(threadRepo, voteRepo, postRepo, userRepo)

	// Middlewares
	router.Use(gin.Recovery())
	router.Use(cors.New(config))

	// Handlers
	rootGroup := router.Group("/api")
	handlers.CreateUserHandler(rootGroup, "/user", userUseCase)
	handlers.CreateForumHandler(rootGroup, "/forum", forumUseCase)
	handlers.CreatePostHandler(rootGroup, "/post", postUseCase)
	handlers.CreateServiceHandler(rootGroup, "/service", serviceUseCase)
	handlers.CreateThreadHandler(rootGroup, "/thread", threadUseCase)

	err = router.Run(":5000")
	if err != nil {
		fmt.Println(err)
	}
}
