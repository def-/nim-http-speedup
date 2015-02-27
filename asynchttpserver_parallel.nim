import asynchttpserver, asyncdispatch, os, strutils

proc cb(req: Request) {.async.} =
  req.respond(Http200, "Hello, World!")

proc run(server: AsyncHttpServer) =
  register(TAsyncFD(server.socket.fd))
  asyncCheck server.serveParallel(cb)
  runForever()

var server = newAsyncHttpServer()
server.initialize(Port(8080))

var threads = newSeq[TThread[AsyncHttpServer]](parseInt(paramStr(1)))
for t in threads.mitems:
  t.createThread run, server
joinThreads threads
