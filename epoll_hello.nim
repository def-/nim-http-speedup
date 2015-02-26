import rawsockets, epoll, unsigned

proc accept4*(a1: SocketHandle, a2: ptr SockAddr, a3: ptr Socklen,
  flags: cint): SocketHandle {.importc, header: "<sys/socket.h>".}

var
  SOCK_NONBLOCK* {.importc, header: "<sys/socket.h>".}: cint
    ## Non-blocking mode.
  SOCK_CLOEXEC* {.importc, header: "<sys/socket.h>".}: cint

var hw = """HTTP/1.0 200 OK
Content-Length: 11

Hello World"""

var sock = newRawSocket()
sock.setSockOptInt(cint(SOL_SOCKET), SO_REUSEADDR, 1)
sock.setBlocking(false)
echo sock.cint

var epollFD = epoll_create(64)
var evs = epoll_event(events: EPOLLIN or EPOLLET, data: epoll_data(fd: cint(sock)))
echo epollFD.epoll_ctl(EPOLL_CTL_ADD, sock, addr evs)

var name: SockAddr_in
name.sin_family = toInt(AF_INET)
name.sin_port = htons(8080)
name.sin_addr.s_addr = htonl(INADDR_ANY)

discard sock.bindAddr(cast[ptr SockAddr](addr name), Socklen(sizeof(name)))
discard sock.listen()

var
  sockAddress: Sockaddr_in
  addrLen = SockLen(sizeof(sockAddress))
  incoming: array[8192, char]
  events: array[64, epoll_event]

while true:
  let evNum = epollFD.epoll_wait(addr events[0], 64, 2000)
  #echo "evNum: ", evNum

  for i in 0 .. <evNum:
    let fd = SocketHandle(events[i].data.fd)
    if (events[i].events and EPOLLIN) != 0:
      if fd == sock:
        #echo "Read, server"
        while true:
          var sock2 = sock.accept4(cast[ptr SockAddr](addr(sockAddress)), addr(addrLen), SOCK_CLOEXEC or SOCK_NONBLOCK)
          if cint(sock2) < 0: break
          var evs2 = epoll_event(events: EPOLLIN or EPOLLOUT or EPOLLET, data: epoll_data(fd: cint(sock2)))
          discard epollFD.epoll_ctl(EPOLL_CTL_ADD, sock2, addr evs2)
      else:
        #echo "Read, no server"
        discard fd.recv(addr incoming, incoming.len, 0)
    if (events[i].events and EPOLLOUT) != 0:
      discard fd.send(addr hw[0], hw.len, int32(MSG_NOSIGNAL))
      fd.close()

sock.close()
