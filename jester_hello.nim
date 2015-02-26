import jester, strtabs, asyncdispatch, os, strutils

let settings = newSettings(port=Port(8080), staticDir=".")

routes:
  get "/":
    resp("Hello World")

runForever()
