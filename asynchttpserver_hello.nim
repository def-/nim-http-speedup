import asynchttpserver, asyncdispatch
var server = newAsyncHttpServer()
proc cb(req: Request) {.async.} =
  #for i in 1..10:
    #var fut = newFuture[string]("asyncnet.acceptAddr")
    #fut.complete("foo")
    #echo repr(fut)
  await req.respond(Http200, "Hello, World!")

asyncCheck server.serve(Port(8080), cb)
runForever()
