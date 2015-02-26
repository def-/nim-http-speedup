wrk -c 400 -d 10 -t 12 http://localhost:8080

Current numbers, with persistent connections:

    jester           5661
    asynchttp       13746
    asyncnet        50806
    selectors       84021
    epoll           86843 (with edge-triggering)
    epoll_parallel 124396 (4 threads)
    epoll_parallel 145422 (8 threads)

For comparison:

    go (1 thread)   23941
    go (4 threads)  58552
    
    cppsp (1 thr.)  26728
    cppsp (4 thr.) 107227

Old numbers, before realizing to use persistent connections:

    sync in nim:
    rawsockets      14259
    
    async in nim:
    jester           5661
    asynchttp       13746
    asyncnet        16255
    selectors       26442
    epoll           31499 (without accept4)
    epoll           32765 (with accept4)
    epoll           36066 (with edge-triggering on first socket)
    epoll           37061 (with edge-triggering on all sockets)

TODO: epoll with edge triggering
