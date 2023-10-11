FROM ubuntu:20.04 as toolchain

ARG RISCV_ARCH=rv32im
ARG RISCV_ABI=ilp32

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    git \    
    curl \
    autoconf automake autotools-dev \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    build-essential \
    bison \
    flex \
    texinfo \
    gperf \
    libtool\ 
    patchutils\ 
    bc \
    zlib1g-dev \
    libexpat-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN git clone --depth=1 https://github.com/riscv/riscv-gnu-toolchain

RUN cd /riscv-gnu-toolchain/ \
    && ./configure --prefix=/opt/riscv --with-arch=$RISCV_ARCH --with-abi=$RISCV_ABI \
    && make -j$(nproc)

FROM ubuntu:20.04 as whisper

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    git \
    build-essential \
    libboost-all-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN git clone --depth=1 https://github.com/chipsalliance/VeeR-ISS

RUN cd /VeeR-ISS \
    && sed -i 's/#include <emmintrin.h>/\/\/#include <emmintrin.h>/g' float.cpp \
    && make -j$(nproc) \
        SOFT_FLOAT=1 \
        BOOST_DIR=/usr/include/boost \
    && mkdir -p /opt/VeeR-ISS \
    && make install INSTALL_DIR=/opt/VeeR-ISS

FROM ubuntu:20.04

LABEL org.opencontainers.image.ref.name=ubuntu
LABEL org.label-schema.version="23.10"

COPY --from=toolchain /opt/riscv /opt/riscv
COPY --from=whisper /opt/VeeR-ISS /opt/VeeR-ISS/bin

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
      git \
      build-essential \
      valgrind \
      verilator \
      gtkwave \
      python3 \
      python3-pip \
      python3-venv \
      python-is-python3 \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

## Graphical apps (gtk) complain if we don't set these variables
ENV LANG="C"
ENV LC_ALL="C"

# Update pip and install Python packages
RUN python -m pip install --upgrade pip \
    && python -m pip install \
      numpy \
      pandas \
      scipy \
      matplotlib \
      seaborn \
      pycachesim \
      pytest 

RUN groupadd bouncmpe -g 1000 \
    && useradd -ms /bin/bash bouncmpe -g 1000 -u 1000 

USER bouncmpe
WORKDIR /home/bouncmpe

ENV PATH=$PATH:/home/bouncmpe/.local/bin:/opt/VeeR-ISS/bin:/opt/riscv/bin

RUN git clone https://github.com/bouncmpe/labs344.git
