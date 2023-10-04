package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
       _, _ = fmt.Fprintf(w, "Simple Server")
    })

    http.HandleFunc("/hi", func(w http.ResponseWriter, r *http.Request) {
       _, _ = fmt.Fprintf(w, "Hi Simple Server")
    })

    log.Fatal(http.ListenAndServe(":9000", nil))
}