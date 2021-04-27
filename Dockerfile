FROM ubuntu:20.04 AS builder

# Env
ENV DEBIAN_FRONTEND noninteractive
ENV INST apt-get install -y

# Dependencies
RUN apt-get update

## Essentials
RUN $INST build-essential git make flex bison libboost-all-dev

## Python
RUN $INST python3 python3-pip
RUN python3 -m pip install pyverilog click liberty-parser cmake

## OpenDB-specific
RUN $INST tcl-dev tk-dev libspdlog-dev swig

# OpenDB
WORKDIR /
RUN git clone --depth 1 https://github.com/cloud-v/Opendbpy
WORKDIR /Opendbpy/src/OpenDB/build
ENV CXXFLAGS -I/usr/include/tcl
RUN cmake  ..
RUN make -j$(nproc)
WORKDIR /Opendbpy/src/OpenDB/build/src/swig/python
RUN python3 setup.py install

WORKDIR /

# -
FROM ubuntu:20.04

# Env
ENV DEBIAN_FRONTEND noninteractive
ENV INST apt-get install -y

# Dependencies 
RUN apt-get update
RUN $INST python3 python3-pip tcl tk libspdlog1
RUN python3 -m pip install pyverilog click

# OpenDB
COPY --from=builder /Opendbpy/src/OpenDB/build/src/swig/python/_opendbpy.so /usr/lib/python3/dist-packages/
COPY --from=builder /Opendbpy/src/OpenDB/build/src/swig/python/opendbpy.py /usr/lib/python3/dist-packages/