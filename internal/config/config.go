package config

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
)

type AppConfig struct {
	SesEmail string
}

func NewConfig() *AppConfig {
	return &AppConfig{
		SesEmail: "",
	}
}

func (ac *AppConfig) GetSesEmail() string {
	sesEmail, ok := os.LookupEnv("SesEmail")
	if !ok {
		fmt.Println("")
		return ac.SesEmail
	}

	return sesEmail
}

func init() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Print("Error loading .env file: ", err)
	}
}
