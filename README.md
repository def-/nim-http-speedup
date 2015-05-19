# Nim HTTP Speedup

The single threaded speedups have been merged into Nim as of 0.11.2.

I'm experimenting with speeding up HTTP servers in Nim. These servers all just return "Hello World". Number of requests per second is measured.

## Optimizing standard library

Trying to optimize asynchttpserver_hello:

https://github.com/def-/nim/tree/parallel-httpserver

                                rqs/s  local  network
    initial state                      13746    13807
    first optimizations (2bf8e42)      18326        -
    some more optimizations (27ba61a)  25524        -
    (671afcd)                          31498    38270
    with --gc:markandsweep             35986    50358
    with --gc:boehm (single threaded)  40361    51973

The very crude parallelization seems to kind of work (but segfaults with
boehm). But the threads are probably getting into  each others way, should make
them use a single epoll instance. Or one thread accepts incoming connections
and spreads them to worker threads.

                                       local  network
    2 threads                          65866    74984
    3 threads                          75175    93101
    4 threads                          72615   115807

    2 threads --gc:markandsweep        76713    76860
    3 threads --gc:markandsweep        87040   118586
    4 threads --gc:markandsweep        78510   124643

## Current numbers, with persistent connections:

All numbers on my Core2Quad Q9300, except where noted otherwise:

    wrk -c 400 -d 10 -t 12 http://localhost:8080

                                rqs/s  local  network
    jester                              6597     7014
    asynchttp                          13746    13807
    asyncnet                           50806        - (broken anyway)
    selectors                          84021        - (broken anyway)
    epoll (with ET)                    86843   121685
    epoll_parallel (4 thr.)           124396   158333
    epoll_parallel (8 thr.)           145422   154844

For comparison:

                                       local  network
    python epoll                        9303     5774 (lots of timeouts, weird)
    h2o (http 1.1)                     39293    46995

    go (1 thread)                      23941    29325
    go (4 threads)                     58552    82170

    cppsp (1 thr.)                     54603    60506
    cppsp (4 thr.)                    110318   141808

On a high performance machine (2x 8-core Xeon E5-2680 (16 cores, 32 threads total)):

    wrk -c 800 -d 10 -t 24 http://127.0.0.1:8080/

    epoll            177345
    epoll (2 thr.)   339530
    epoll (4 thr.)   627846
    epoll (8 thr.)  1048415
    epoll (16 thr.) 1532484

## Old numbers, before realizing to use persistent connections:

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
