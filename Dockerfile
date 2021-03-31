FROM ubuntu:20.04

# Env
ENV DEBIAN_FRONTEND noninteractive
ENV INST apt-get install -y

# Dependencies
RUN apt-get update

# Essentials
RUN $INST build-essential git make flex bison libboost-all-dev

## Python
RUN $INST python3 python3-pip
RUN python3 -m pip install pyverilog click cmake

## OpenDB-specific
RUN $INST tcl-dev tk-dev libspdlog-dev swig

# OpenDB
WORKDIR /
RUN git clone https://github.com/ax3ghazy/opendb
WORKDIR /opendb/build
RUN cmake ..
RUN make -j$(nproc)
WORKDIR /opendb/build/src/swig/python
RUN python3 setup.py install

WORKDIR /
