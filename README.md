wrk -c 400 -d 10 -t 12 http://localhost:8080

Current numbers:

                    Req/s
    go (4 threads)  58552
    cppsp (4 thr.) 107227
    
    sync in nim:
    rawsockets      14259
    
    async in nim:
    jester           5661
    asynchttp       13746
    asyncnet        16255
    selectors       26442
    
    parallel (2)    32222
    parallel (4)    33268
    parallel (8)    33667

TODO: epoll with edge triggering
