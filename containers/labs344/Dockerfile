ARG LABS344_CONTAINER_VERSION=latest
ARG LABS344_CONTAINER_BASE_IMAGE=docker.io/almalinux/10-base:10

ARG LABS344_CONTAINER_BUILDER_IMAGE=labs344-builder
ARG LABS344_CONTAINER_DEVEL_IMAGE=labs344-devel

ARG RISCV_GNU_TOOLCHAIN_VERSION=23863c2ca74e6c050f0c97e7af61f5f1776aadd1
ARG RISCV_INSTALL_PREFIX=/opt/riscv

ARG WALLY_VERSION=407c74799bce0968b21551eba72864c2c6ead987
ARG ELF2HEX_VERSION=f28a3103c06131ed3895052b1341daf4ca0b1c9c
ARG SPIKE_VERSION=4c870d063dbbaeb4dc7007fe5c2a1bf8b00a767e
ARG VERILATOR_VERSION=v5.036

FROM ${LABS344_CONTAINER_BASE_IMAGE} as labs344-base
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

RUN dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release && \
    dnf clean all

RUN dnf install -y \
      dtc \
      mold \
      perl \
      && \ 
    dnf clean all

FROM labs344-base as labs344-toolchain
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

ARG RISCV_GNU_TOOLCHAIN_VERSION
ENV RISCV_GNU_TOOLCHAIN_VERSION=${RISCV_GNU_TOOLCHAIN_VERSION}

ARG RISCV_INSTALL_PREFIX
ENV RISCV_INSTALL_PREFIX=${RISCV_INSTALL_PREFIX}
ENV PATH="${RISCV_INSTALL_PREFIX}/bin:${PATH}"

RUN dnf install -y \
      git \
      autoconf \
      automake \
      python3 \
      libmpc-devel \
      mpfr-devel \
      gmp-devel \
      gawk  \
      bison \
      flex \
      texinfo \
      diffutils \
      patchutils \
      gcc \
      gcc-c++ \
      cmake \
      ninja-build \
      ccache \
      zlib-devel \
      expat-devel \
      libslirp-devel \
    && dnf clean all

RUN git clone  https://github.com/riscv/riscv-gnu-toolchain.git \
        --no-checkout \
        /tmp/riscv-gnu-toolchain \
        &&\
    cd /tmp/riscv-gnu-toolchain && \
    git checkout ${RISCV_GNU_TOOLCHAIN_VERSION} && \
    export CFLAGS='-g0 -DNDEBUG' && \
    export CPPFLAGS='-g0 -DNDEBUG' && \
    ./configure \
        --prefix="${RISCV_INSTALL_PREFIX}" \
        --with-multilib-generator="\
          rv32e-ilp32e--; \
          rv32i-ilp32--; \
          rv32im-ilp32--; \
          rv32iac-ilp32--; \
          rv32imac-ilp32--; \
          rv32imafc-ilp32f--; \
          rv32imafdc-ilp32d--; \
          rv64i-lp64--; \
          rv64ic-lp64--; \
          rv64iac-lp64--; \
          rv64imac-lp64--; \
          rv64imafdc-lp64d--; \
          rv64im-lp64--; \
        "\
        && \
    make -j"$(nproc)" && \
    rm -rf /tmp/riscv-gnu-toolchain

RUN git clone https://github.com/sifive/elf2hex.git \
        --no-checkout \
        /tmp/elf2hex \
        &&\
    cd /tmp/elf2hex && \
    git checkout ${ELF2HEX_VERSION} && \
    export CFLAGS='-g0 -DNDEBUG' && \
    export CPPFLAGS='-g0 -DNDEBUG' && \
    ./configure --prefix="/usr/local" && \
    make -j"$(nproc)" && \
    make install && \
    rm -rf /tmp/elf2hex

RUN git clone https://github.com/riscv-software-src/riscv-isa-sim \
        --no-checkout \
        /tmp/riscv-isa-sim \
        &&\
    cd /tmp/riscv-isa-sim && \
    git checkout ${RISCV_ISA_SIM_VERSION} && \
    export CFLAGS='-g0 -DNDEBUG' && \
    export CPPFLAGS='-g0 -DNDEBUG' && \
    ./configure --prefix="/usr/local" && \
    make -j"$(nproc)" && \
    make install && \
    rm -rf /tmp/riscv-isa-sim

RUN git clone https://github.com/verilator/verilator \
        --no-checkout \
        /tmp/verilator \
        &&\
    cd /tmp/verilator && \
    git checkout ${VERILATOR_VERSION} && \ 
    cmake -S . -B build -G Ninja \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_BUILD_TYPE=Release \
        && \
    cmake --build build -j"$(nproc)" && \
    cmake --install build && \
    rm -rf /tmp/verilator

FROM labs344-base as labs344-devel
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

ARG RISCV_INSTALL_PREFIX
ENV RISCV_INSTALL_PREFIX=${RISCV_INSTALL_PREFIX}

ARG WALLY_VERSION
ENV WALLY_VERSION=${WALLY_VERSION}

COPY --from=labs344-toolchain ${RISCV_INSTALL_PREFIX} ${RISCV_INSTALL_PREFIX}
COPY --from=labs344-toolchain /usr/local /usr/local

ENV WALLY_SOURCE_DIR=/opt/openhwgroup/cvw

ENV LABS344_HOME=/root
ENV LABS344_SOURCE_DIR=/workspaces/labs344
ENV LABS344_PYTHON_VENV_DIR=${LABS344_HOME}/.venv/labs344
ENV LABS344_PYTHON_EXECUTABLE=${LABS344_PYTHON_VENV_DIR}/bin/python

# Aliases used in Wally scripts
ENV RISCV=${RISCV_INSTALL_PREFIX}
ENV WALLY=${WALLY_SOURCE_DIR}

RUN dnf install -y \
      git \
      wget \
      vim \
      emacs \
      nano \
      gtkwave \
      && \ 
    dnf clean all

RUN git clone https://github.com/openhwgroup/cvw.git \
        --no-checkout \
        ${WALLY_SOURCE_DIR} \
        &&\
    cd ${WALLY_SOURCE_DIR} && \
    git fetch --depth 1 origin ${WALLY_VERSION} && \
    git checkout FETCH_HEAD && \
    git submodule update --init --recursive

ENV PATH="${RISCV_INSTALL_PREFIX}/bin:${PATH}"
ENV NO_AT_BRIDGE=1
