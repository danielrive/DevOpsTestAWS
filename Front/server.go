package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	fmt.Println("Creating a listener for the server")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
	// Defining function to manage the request

	http.HandleFunc("/home", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello!")
	})

}
