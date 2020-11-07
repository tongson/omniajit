#!/usr/bin/env moon
T = require"u-test"
C = require"curler"
J = require"lunajson"

T["Post JSON"]= ->
    json = J.encode {
        name: "Joe"
        address: "US"
    }
    curl = C.json!
    curl.data = json
    R = curl "https://reqres.in/api/users"
    T.equal R.name, "Joe"
    T.equal R.address, "US"
    T.is_string R.id
T["Post URL encoded data"] = ->
    curl = C.encoded!
    curl.data = "hand=wave"
    R = curl "https://postman-echo.com/post"
    json = J.decode R
    T.equal json.data, "hand=wave"
T["Headers"] = ->
    curl = C.get!
    curl.headers = { header: "value" }
    R = curl "https://postman-echo.com/get"
    json = J.decode R
    T.equal json.headers.header, "value"
T["HEAD"] = ->
    curl = C.head!
    curl.headers = { header: "value" }
    R = curl "https://postman-echo.com/head"
    T.equal R, "200"

T.summary!
