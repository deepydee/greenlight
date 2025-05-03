package main

import (
	"fmt"
	"net/http"
)

func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	_, err := fmt.Fprintln(w, "status: available")
	if err != nil {
		return
	}
	_, err = fmt.Fprintf(w, "environment: %s\n", app.config.env)
	if err != nil {
		return
	}
	_, err = fmt.Fprintf(w, "version: %s\n", version)
	if err != nil {
		return
	}
}
