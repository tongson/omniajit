#!/usr/bin/env moon
T = require "u-test"
import compile, render, Parser from require "etlua"

do
  do
    cases = {
      {
        "hello world"
        "hello world"
      }

      {
        "one surf-zone two"
        "one <%= var %> two"
        {var: "surf-zone"}
      }

      {
        "a ((1))((2))((3)) b"
        "a <% for i=1,3 do %>((<%= i %>))<% end %> b"
      }

      {
        "y%&gt;u"
        [[<%= "y%>u" %>]]
      }

      {
        "y%>u"
        [[<%- "y%>u" %>]]
      }

      {
        [[
This is my message to you
This is my message to 4



  hello 1
  hello 2
  hello 3
  hello 4
  hello 5
  hello 6
  hello 7
  hello 8
  hello 9
  hello 10

message: yeah

This is my message to oh yeah  %&gt;&quot;]]
        [[
This is my message to <%= "you" %>
This is my message to <%= 4 %>
<% if things then %>
  I love things
<% end %>

<% for i=1,10 do%>
  hello <%= i -%>
<% end %>

message: <%= visitor %>

This is my message to <%= [=[oh yeah  %>"]=] %>]]
        {
          visitor: "yeah"
        }
      }


      {
        "hello"
        "<%= 'hello' -%>
"
      }


      -- should have access to _G
      {
        ""
        "<% assert(true) %>"
        { hello: "world" }
      }
    }

    for case in *cases
      T["should render template"] = ->
        T.equal(case[1], render(unpack(case, 2)))

    T["should error on unclosed tag"] = ->
      v, e = render "hello <%= world"
      T.is_nil(v)
      T.equal(e, "failed to find closing tag [1]: hello <%= world")

    T["should fail on bad interpolate tag"] = ->
      v, e = render "hello <%= if hello then print(nil) end%>"
      T.is_nil(v)
      T.equal(e, "unexpected symbol near 'if' [1]: hello <%= if hello then print(nil) end%>")

    T["should fail on bad code tag"] = ->
      v, e = render [[
          what is going on
          hello <% howdy doody %>
          there is nothing left
        ]]
      T.is_nil(v)
      T.equal(e, "'=' expected near 'doody' [2]:           hello <% howdy doody %>")

    T["should use existing buffer"] = ->
      fn = compile "hello<%= 'yeah' %>"
      buff = {"first"}
      out = fn {}, buff, #buff
      T.equal "firsthelloyeah", out

    T["should compile readme example"] = ->
      parser = Parser!

      first_fn = parser\load parser\compile_to_lua "Hello "
      second_fn = parser\load parser\compile_to_lua "World"

      buffer = {}
      parser\run first_fn, nil, buffer, #buffer
      parser\run second_fn, nil, buffer, #buffer

      T.equal "Hello World", table.concat buffer

  do
    cases = {
      { "hello world", false }
      { "hello 'world", true }
      { [[hello "hello \" world]], true }
      { "hello [=[ wor'ld ]=]dad", false }
    }

    for {str, expected} in *cases
      T["should detect if in string"] = ->
        T.equal expected, Parser.in_string { :str }, 1
