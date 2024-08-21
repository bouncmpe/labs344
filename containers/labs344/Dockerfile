FROM ubuntu:24.04 AS toolchain
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

ARG RISCV_ARCH=rv32im
ARG RISCV_ABI=ilp32

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -qqy \
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
      gnupg2 \
      ca-certificates \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN git clone -j"$(nproc)" https://github.com/riscv/riscv-gnu-toolchain /riscv-gnu-toolchain
WORKDIR /riscv-gnu-toolchain
RUN ./configure --prefix=/opt/riscv --with-arch=${RISCV_ARCH} --with-abi=${RISCV_ABI} && \
    make -j"$(nproc)"

FROM docker.io/library/ubuntu:22.04 AS whisper-builder
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -qqy --no-install-recommends \
        git \
        wget \
        gnupg2 \
        ca-certificates \
        build-essential \
        libboost-all-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

# TODO(doganulus): Until the fix is merged, we need to clone the fix-cross-compile branch
RUN git clone https://github.com/chipsalliance/VeeR-ISS && \
    cd /VeeR-ISS && \
    git fetch origin pull/36/head:fix-cross-compile && \
    git switch fix-cross-compile && \
    make -j$(nproc) \
        SOFT_FLOAT=1 \
        BOOST_DIR=/usr/include/boost && \
    mkdir -p /opt/VeeR-ISS && \
    make install INSTALL_DIR=/opt/VeeR-ISS

FROM docker.io/library/ubuntu:24.04 AS labs344
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
        sudo \
        git \
        wget \
        gnupg2 \
        ca-certificates \
        verilator \
        gtkwave \
        make \
    && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# COPY --from=toolchain /opt/riscv /opt/riscv
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
        gcc-riscv64-unknown-elf \
        binutils-riscv64-unknown-elf \
    && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

COPY --from=whisper-builder /opt/VeeR-ISS/whisper /usr/local/bin/whisper    

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
        python3-minimal \
        python3-pip \
        python3-numpy \
        python3-scipy \
        python3-matplotlib \
        python3-pandas \
    && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8

USER ubuntu
WORKDIR /home/ubuntu
