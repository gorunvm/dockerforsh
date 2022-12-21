package main

import (
    "io"
    "net/http"
)

func main() {
    http.HandleFunc("/", doRequest)
    http.ListenAndServe(":80", nil)
}

func doRequest(w http.ResponseWriter, r *http.Request) {
    io.WriteString(w, "hello world!")
}
