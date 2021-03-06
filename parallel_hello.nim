import rawsockets, selectors

type Data* = ref object of RootRef
  socket: SocketHandle
  isServer: bool
  done: bool

proc run(x: tuple[t: int, s: SocketHandle]) {.thread.} =
  echo "Hi from thread ", x.t
  var hw = """HTTP/1.1 200 OK
Connection: close
Content-Length: 11

Hello World"""

  var sel = newSelector()
  var data = Data(socket: x.s, isServer: true, done: false)
  sel.register(x.s, {EvRead}, data)

  var
    sockAddress: Sockaddr_in
    addrLen = SockLen(sizeof(sockAddress))
    incoming: array[8192, char]

  while true:
    for info in sel.select(1000):
      let data = Data(info[0].data)
      if EvRead in info.events:
        if data.isServer:
          #echo "Reading in thread ", x.t
          #echo "Read, server"
          var sock2 = data.socket.accept(cast[ptr SockAddr](addr(sockAddress)), addr(addrLen))
          if int(sock2) > -1:
            sock2.setBlocking(false)
            var data2 = Data(socket: sock2, isServer: false)
            sel.register(sock2, {EvRead, EvWrite}, data2)
        else:
          #echo "Read, not server"
          discard data.socket.recv(addr incoming, incoming.len, 0)
      if EvWrite in info.events:
        if not data.done:
          #echo "Write, not done"
          discard data.socket.send(addr hw[0], hw.len, int32(MSG_NOSIGNAL))
          data.done = true
        else:
          #echo "Write, done"
          data.socket.close()
          sel.unregister(data.socket)

  #sock.close()

const n = 4

var threads: array[n, Thread[tuple[t: int, s: SocketHandle]]]

var sock = newNativeSocket()
sock.setSockOptInt(cint(SOL_SOCKET), SO_REUSEADDR, 1)
sock.setBlocking(false)

var name: SockAddr_in
name.sin_family = toInt(AF_INET)
name.sin_port = htons(8080'u16)
name.sin_addr.s_addr = htonl(INADDR_ANY)

discard sock.bindAddr(cast[ptr SockAddr](addr name), Socklen(sizeof(name)))
discard sock.listen()

for i in 0 .. <n:
  threads[i].createThread(run, (i, sock))

joinThreads threads
