ARG LABS344_RHEL_BASE_IMAGE=ghcr.io/almalinux/almalinux
ARG LABS344_RHEL_VERSION=9

ARG LABS344_RISCV_GNU_TOOLCHAIN_VERSION=23863c2ca74e6c050f0c97e7af61f5f1776aadd1

FROM ${LABS344_RHEL_BASE_IMAGE}:${LABS344_RHEL_VERSION} AS labs344-builder
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

RUN dnf install -y git && \
    dnf install -y --allowerasing curl && \
    dnf clean all

RUN git clone --recurse-submodules https://github.com/openhwgroup/cvw /tmp/cvw && \
    cd /tmp/cvw && \
    git checkout main && \
    export WALLY=$(pwd) && \
    export RISCV=/opt/riscv && \
    export PYTHON_VERSION=python3.12 && \
    bash -c ". $WALLY/bin/wally-environment-check.sh" && \
    bash -c ". $WALLY/bin/wally-package-install.sh" && \
    cd .. && rm -rf /tmp/cvw && \
    dnf clean all

FROM ${LABS344_RHEL_BASE_IMAGE}:${LABS344_RHEL_VERSION} AS labs344-toolchain
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

RUN dnf install -y \
      git \
      dnf-plugins-core \
      dnf-plugin-config-manager \
      epel-release \
      && \
    dnf config-manager --enable crb && \
    dnf clean all

RUN dnf install -y \
      autoconf \
      automake \
      python3.12 \
      libmpc-devel \
      mpfr-devel \
      gmp-devel \
      gawk \
      bison \
      flex \
      texinfo \
      patchutils \
      gcc-toolset-14-gcc \
      gcc-toolset-14-gcc-c++ \
      zlib-devel \
      expat-devel \
      libslirp-devel \
      make \
      cmake \
      ninja-build \
      && \
    dnf clean all

ARG LABS344_RISCV_GNU_TOOLCHAIN_VERSION
ENV LABS344_RISCV_GNU_TOOLCHAIN_VERSION=${LABS344_RISCV_GNU_TOOLCHAIN_VERSION}
ENV LABS344_RISCV_DIR=/opt/riscv
ENV PATH=${LABS344_RISCV_DIR}/riscv-gnu-toolchain/bin:$PATH

RUN . /opt/rh/gcc-toolset-14/enable && \
    git clone https://github.com/riscv/riscv-gnu-toolchain /tmp/riscv-gnu-toolchain && \
    cd /tmp/riscv-gnu-toolchain && \
    ./configure --prefix=${LABS344_RISCV_DIR} --enable-multilib --with-multilib-generator="rv32e-ilp32e--;rv32i-ilp32--;rv32im-ilp32--;rv32iac-ilp32--;rv32imac-ilp32--;rv32imafc-ilp32f--;rv32imafdc-ilp32d--;rv64i-lp64--;rv64ic-lp64--;rv64iac-lp64--;rv64imac-lp64--;rv64imafdc-lp64d--;rv64im-lp64--;" && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/riscv-gnu-toolchain

FROM labs344-builder AS labs344-tools
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

FROM ${LABS344_RHEL_BASE_IMAGE}:${LABS344_RHEL_VERSION} AS labs344
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

COPY --from=labs344-toolchain /opt/riscv /opt/riscv
