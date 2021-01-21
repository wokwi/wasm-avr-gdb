# AVR-GCC + Emscripten build environment
# Copyright (C) 2021, Uri Shaked.

FROM ubuntu:20.04

# These two lines ensure tzdata doesn't bug use during apt-get install below:
ENV TZ=GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y wget gcc g++ make python3 git xz-utils texinfo

## Install EMScripten SDK

WORKDIR /opt

RUN git clone https://github.com/emscripten-core/emsdk.git

WORKDIR /opt/emsdk

RUN ./emsdk install latest
RUN ./emsdk activate latest

RUN echo "source $(pwd)/emsdk_env.sh" >> ~/.bashrc

### Download GDB 10.1 sources

RUN mkdir /build
WORKDIR /build
RUN wget https://ftp.gnu.org/gnu/gdb/gdb-10.1.tar.xz
RUN tar xf gdb-10.1.tar.xz

### Apply patches
WORKDIR /build/gdb-10.1
COPY patches/gdb-wasm.patch /build/gdb-10.1/gdb-wasm.patch
RUN patch -i gdb-wasm.patch -p0

### Build GDB
RUN bash -c 'source /opt/emsdk/emsdk_env.sh && emconfigure  ./configure --target=avr --with-static-standard-libraries'
RUN bash -c 'source /opt/emsdk/emsdk_env.sh && emmake make'

### Have fun!
