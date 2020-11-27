#!/usr/bin/env ../bin/moon
T = require"u-test"
C = require"curlr"
J = require"json"

T["Post JSON"]= ->
    j = J.encode {
        name: "Joe"
        address: "US"
    }
    curl = C.json!
    curl.data = j
    R = curl "https://postman-echo.com/post"
    T.equal R.url, 'https://postman-echo.com/post'
    T.is_table R.json
    T.is_table R.headers
    T.is_table R.args
    T.is_table R.files
    T.is_table R.form
T["Post URL encoded data"] = ->
    curl = C.encoded!
    curl.data = "hand=wave"
    R = curl "https://postman-echo.com/post"
    data = J.decode R
    T.equal data.url, 'https://postman-echo.com/post'
    T.is_table data.json
    T.is_table data.headers
    T.is_table data.args
    T.is_table data.files
    T.is_table data.form
T["Headers"] = ->
    curl = C.get!
    curl.headers = { header: "value" }
    R = curl "https://postman-echo.com/get"
    data = J.decode R
    T.equal data.url, 'https://postman-echo.com/get'
T["Head"] = ->
    curl = C.head!
    curl.headers = { header: "value" }
    R = curl "https://postman-echo.com/head"
    T.equal R, "'200'"

T.summary!
