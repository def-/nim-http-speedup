import jester, asyncdispatch, asyncnet, strtabs

proc match(request: PRequest, response: PResponse): Future[bool] {.async.} =
  result = true
  #await response.client.send("HTTP/1.1 200 OK\c\LContent-Length: 11\c\L\c\LHello World")
  response.data.headers = newStringTable()
  resp(Http200, "Hello World!")
  #await response.sendHeaders()
  #await response.send("Hello World")
  #response.client.close()

let settings = newSettings(port=Port(8080), staticDir=".")

jester.serve(match, settings=settings)
runForever()
