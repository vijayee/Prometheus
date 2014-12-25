package main

import (
	"github.com/go-martini/martini"
	"io/ioutil"
	"fmt"
	"github.com/martini-contrib/cors"
	"github.com/mytrile/nocache"
	"net/http"
	"encoding/json"
	"github.com/robertkrimen/otto"
	"log"
)
func main() {
	server:= martini.Classic()
	server.Use(martini.Static("../public"))
	server.Use(martini.Static("../assets/javascript/app"))
	server.Use(nocache.UpdateCacheHeaders())
	server.Use(cors.Allow(&cors.Options{
		AllowOrigins:     []string{"https://localhost:3000"},
		AllowMethods:     []string{"POST", "GET"},
		AllowHeaders:     []string{"Origin", "Content-Type"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))
	server.Get("/")
	server.Post("/calculator", Calculate)

	log.Fatal(http.ListenAndServeTLS(":3000", "cert.pem", "key.pem", server))
}
type Calculation struct{
	Calculation string
	Result float64
}

func Calculate(response http.ResponseWriter, request *http.Request, params martini.Params){
	bodyBytes, err := ioutil.ReadAll(request.Body)
	if err != nil {
		return
	}

	var toCalc Calculation
	err = json.Unmarshal(bodyBytes, &toCalc)
	if err != nil {
		http.Error(response, "Failed to Parse JSON", http.StatusInternalServerError)
		return
	}
	if toCalc.Calculation == "" {
		return
	}
	runner:=otto.New()
	result, err:= runner.Run(toCalc.Calculation)
	if err != nil {
		http.Error(response, err.Error(), http.StatusInternalServerError)
		return
	}
	toCalc.Result, _= result.ToFloat()
	responseBytes, err := json.Marshal(toCalc)
	if err != nil {
		http.Error(response, "Failed to Encode JSON", http.StatusInternalServerError)
		return
	}

	fmt.Fprint(response, string(responseBytes))
	return
}

