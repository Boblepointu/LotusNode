FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -qy libatomic1

RUN mkdir /src

WORKDIR /src

COPY bin /src/bin
COPY include /src/include
COPY lib /src/lib

CMD ./bin/lotusd -rest=1 -rpcallowip=0.0.0.0/0 -rpcthreads=8  -rpcuser=lotus -rpcpassword=lotus -rpcport=10604