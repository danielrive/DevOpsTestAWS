package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

// Response  format for api response
type Response struct {
	ID     string `json:"id"`
	Joke   string `json:"joke"`
	Status int    `json:"status"`
}

func main() {
	// Defining function to manage the request
	PORT := goDotEnvVariable("PORT")
	http.HandleFunc("/home", homeHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/wantajoke", wantajokeHandler)

	fmt.Println("Creating a listener for the server")
	if err := http.ListenAndServe(":"+PORT, nil); err != nil {
		log.Fatal(err)
	}

}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/home" {
		http.Error(w, "404 not found.", http.StatusNotFound)
		return
	}

	if r.Method != "GET" {
		http.Error(w, "Method is not supported.", http.StatusNotFound)
		return
	}

	fmt.Fprintf(w, "Welcome to test page by Daniel Rivera !!!")
}

func wantajokeHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/wantajoke" {
		http.Error(w, "404 not found.", http.StatusNotFound)
		return
	}
	client := &http.Client{}
	req, err := http.NewRequest("GET", "https://icanhazdadjoke.com/", nil)
	if err != nil {
		fmt.Print(err.Error())
	}
	req.Header.Add("Accept", "application/json")
	req.Header.Add("Content-Type", "application/json")
	resp, err := client.Do(req)
	defer resp.Body.Close()
	bodyBytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Print(err.Error())
	}
	var responseObject Response
	json.Unmarshal(bodyBytes, &responseObject)
	fmt.Fprintf(w, "Here is your Joke :) !!!\n")
	fmt.Fprintf(w, "\n%v\n", responseObject.Joke)
	fmt.Printf("API Response as struct %+v\n", responseObject)

}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/health" {
		http.Error(w, "404 not found.", http.StatusNotFound)
		return
	}

	if r.Method != "GET" {
		http.Error(w, "Method is not supported.", http.StatusNotFound)
		return
	}

	fmt.Fprintf(w, "Service is UP")
}

func goDotEnvVariable(key string) string {

	// load .env file
	err := godotenv.Load(".env")

	if err != nil {
		log.Fatalf("Error loading .env file")
	}

	return os.Getenv(key)
}
