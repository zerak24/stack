package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    http.HandleFunc("/user", func(w http.ResponseWriter, r *http.Request) {
       _, _ = fmt.Fprintf(w, "User Simple Server")
    })

    http.HandleFunc("/public", func(w http.ResponseWriter, r *http.Request) {
       _, _ = fmt.Fprintf(w, "Public Simple Server")
    })

    log.Fatal(http.ListenAndServe(":9000", nil))
}