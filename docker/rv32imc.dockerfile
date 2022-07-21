FROM ubuntu:20.04 as builder

ARG RISCV_ARCH=rv32imc
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

RUN git clone --depth=1 --recursive https://github.com/riscv/riscv-gnu-toolchain

RUN cd /riscv-gnu-toolchain/ \
    && ./configure --prefix=/opt/riscv --with-arch=$RISCV_ARCH --with-abi=$RISCV_ABI\
    && make -j$(nproc)

FROM ubuntu:20.04 
COPY --from=builder /opt/riscv /opt/riscv
