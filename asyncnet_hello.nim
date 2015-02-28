import asyncnet, asyncdispatch

const text =  """HTTP/1.1 200 OK
Content-Length: 11

Hello World"""

proc processClient(client: AsyncSocket) {.async.} =
  var buf = newString(8192)
  while true:
    #let line = await recvLineInto(cast[ptr cstring](addr buf[0]), 8192, client)
    #let read = await readInto(buf.cstring, 8192, client, {})
    await client.send(text)
  #client.close()

proc serve() {.async.} =
  var server = newAsyncSocket()
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(Port(8080))
  server.listen()

  var future = newFuture[AsyncSocket]("asyncnet.accept")

  while true:
    let client = await server.accept()

    asyncCheck processClient(client)

asyncCheck serve()
runForever()
