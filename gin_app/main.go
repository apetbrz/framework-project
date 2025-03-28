package main

import (
	"math/rand"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

type PasswordMsg struct {
	Password string `json:"password" binding:"required"`
}

func main() {
	r := gin.New()

	r.LoadHTMLGlob("dynamic/*")

	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "gin webserver for spring 2025 senior project - arthur petroff")
	})

	r.GET("/hello", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, world!",
		})
	})

	r.StaticFile("/static", "static/gin_static_page.html")

	r.GET("/dynamic", func(c *gin.Context) {
		c.HTML(http.StatusOK, "gin_dynamic_page.tmpl", gin.H{
			"headerValue":  c.Request.Header.Get("Experimental-Data"),
			"randomNumber": rand.Float32(),
		})
	})

	r.POST("/hash", func(c *gin.Context) {
		var pw PasswordMsg
		c.BindJSON(&pw)
		hash, _ := bcrypt.GenerateFromPassword([]byte(pw.Password), 8)
		c.JSON(http.StatusOK, &PasswordMsg{Password: string(hash)})
	})

	r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
