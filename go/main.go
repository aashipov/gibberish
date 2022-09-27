package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/google/uuid"
)

const (
	slash           = "/"
	canNotEvaluate = "Can not evaluate"
	welcome = "Welcome to gibberish service\nHTTP POST your stuff and enjoy gibberish"
)

func enableGracefulShutdown(server *http.Server) {
	gracefulShutdown := make(chan os.Signal)
	signal.Notify(gracefulShutdown, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		sig := <-gracefulShutdown
		log.Printf("%s received, shutdown", sig)
		server.Close()
		os.Exit(0)
	}()
}

func textResponse(w http.ResponseWriter, txt string) {
	w.Write([]byte(txt))
}

func generateUuid() string {
	return uuid.New().String()
}

func gibberish(w http.ResponseWriter, r *http.Request) {
	b, err := io.ReadAll(r.Body)
		if err != nil {
			log.Println(canNotEvaluate)
			textResponse(w, canNotEvaluate)
		}
		result := generateUuid() + string(b) + generateUuid() + "\n"
		textResponse(w, result)
}

func handler(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodPost:
		gibberish(w, r)
	default:
		textResponse(w, welcome)
	}
}

func main() {
	http.HandleFunc(slash, handler)
    server := http.Server{Addr: ":8080", Handler: nil}
	enableGracefulShutdown(&server)
	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}
