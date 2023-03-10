FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -qy libatomic1 nginx apache2-utils

RUN mkdir /src

WORKDIR /src

COPY bin /src/bin
COPY include /src/include
COPY lib /src/lib
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY lotus-miner-0.0.1.tar.gz /lotus-miner-0.0.1.tar.gz
COPY lotus-miner-0.0.2.tar.gz /lotus-miner-0.0.2.tar.gz
COPY lotus-miner-0.0.3.tar.gz /lotus-miner-0.0.3.tar.gz

CMD /usr/sbin/nginx && \
    ./bin/lotusd -rest=1 -rpcallowip=0.0.0.0/0 -rpcthreads=8  -rpcuser=lotus -rpcpassword=lotus -rpcport=10604 -disablewallet -datadir=/root/.lotus