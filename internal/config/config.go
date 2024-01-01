package config

import (
	"log"

	"github.com/joho/godotenv"
)

func init() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Print("Error loading .env file: ", err)
	}
}
