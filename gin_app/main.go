package main

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

type PasswordMsg struct {
	Password string `json:"password" binding:"required"`
}

func main() {
	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, world!",
		})
	})

	r.POST("/hash", func(c *gin.Context) {
		var password PasswordMsg
		fmt.Println("incoming: ", c.Request.Body)
		c.BindJSON(&password)
		fmt.Println(password.Password)
		hash, _ := bcrypt.GenerateFromPassword([]byte(password.Password), 8)
		fmt.Println(string(hash))
		c.JSON(http.StatusOK, &PasswordMsg{Password: string(hash)})
	})

	r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
