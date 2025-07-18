ARG LABS344_VERSION=latest
ARG LABS344_DEBIAN_VERSION=12
ARG LABS344_IMAGE_REGISTRY=localhost
ARG LABS344_IMAGE_REGISTRY_REMOTE=${LABS344_IMAGE_REGISTRY}
ARG LABS344_IMAGE_NAME=labs344
ARG LABS344_IMAGE_NAME_FULL=${LABS344_IMAGE_REGISTRY}/${LABS344_IMAGE_NAME}
ARG LABS344_IMAGE_VERSION=${LABS344_VERSION}
ARG LABS344_BUILDER_IMAGE=${LABS344_IMAGE_NAME_FULL}:${LABS344_IMAGE_VERSION}-builder
ARG LABS344_TOOLCHAIN_IMAGE=${LABS344_IMAGE_NAME_FULL}:${LABS344_IMAGE_VERSION}-toolchain
ARG LABS344_TOOLS_IMAGE=${LABS344_IMAGE_NAME_FULL}:${LABS344_IMAGE_VERSION}-tools

ARG LABS344_RISCV_GNU_TOOLCHAIN_VERSION=23863c2ca74e6c050f0c97e7af61f5f1776aadd1

FROM docker.io/library/debian:${LABS344_DEBIAN_VERSION} AS labs344-toolchain
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -qy --no-install-recommends \
      autoconf \
      automake \
      autotools-dev \
      curl \
      python3 \
      python3-pip \
      python3-tomli \
      libmpc-dev \
      libmpfr-dev \
      libgmp-dev \
      gawk \
      build-essential \
      bison \
      flex \
      texinfo \
      gperf \
      libtool \
      patchutils \
      bc \
      zlib1g-dev \
      libexpat-dev \
      ninja-build \
      git \
      cmake \
      libglib2.0-dev \
      libslirp-dev \
      && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ARG LABS344_RISCV_GNU_TOOLCHAIN_VERSION
ENV LABS344_RISCV_GNU_TOOLCHAIN_VERSION=${LABS344_RISCV_GNU_TOOLCHAIN_VERSION}
ENV LABS344_RISCV_DIR=/opt/riscv
ENV PATH=${LABS344_RISCV_DIR}/riscv-gnu-toolchain/bin:$PATH

RUN git clone https://github.com/riscv/riscv-gnu-toolchain /tmp/riscv-gnu-toolchain && \
    cd /tmp/riscv-gnu-toolchain && \
    ./configure --prefix=${LABS344_RISCV_DIR} --enable-multilib --with-multilib-generator="rv32e-ilp32e--;rv32i-ilp32--;rv32im-ilp32--;rv32iac-ilp32--;rv32imac-ilp32--;rv32imafc-ilp32f--;rv32imafdc-ilp32d--;rv64i-lp64--;rv64ic-lp64--;rv64iac-lp64--;rv64imac-lp64--;rv64imafdc-lp64d--;rv64im-lp64--;" && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/riscv-gnu-toolchain

FROM ${LABS344_TOOLCHAIN_IMAGE} AS labs344-tools
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

RUN git clone https://github.com/sifive/elf2hex.git /tmp/elf2hex && \
    cd /tmp/elf2hex && \
    autoreconf -i && \
    ./configure --target=riscv64-unknown-elf --prefix=${LABS344_RISCV_DIR} && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/elf2hex

RUN git clone https://github.com/riscv-software-src/riscv-isa-sim /tmp/riscv-isa-sim && \
    mkdir -p /tmp/riscv-isa-sim/build && \
    cd /tmp/riscv-isa-sim/build && \
    ../configure --prefix=${LABS344_RISCV_DIR} && \
    make -j$(nproc) && \
    make install && \
    && rm -rf /tmp/riscv-isa-sim

FROM docker.io/library/debian:${LABS344_DEBIAN_VERSION} AS labs344
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

COPY --from=labs344-tools /opt/riscv /opt/riscv

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -qqy --no-install-recommends \
        curl \
        wget \
        git \
        gnupg2 \
        ca-certificates \
        build-essential \
        make \
        cmake \
        ninja-build \
        python3-minimal \
        python3-pip \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

FROM ${LABS344_BUILDER_IMAGE} AS labs344-devel
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

RUN git clone https://github.com/openhwgroup/cvw && \
    cd cvw && \
    git checkout main && \
    git submodule update --init --recursive && \
    export WALLY=$(pwd) && \
    export RISCV=/opt/riscv && \
    export PYTHON_VERSION=python3.11 && \
    bash -c ". $WALLY/bin/wally-environment-check.sh" && \
    bash -c ". $WALLY/bin/wally-package-install.sh" && \
    bash -c ". $WALLY/bin/installation/python-setup.sh" && \
    bash -c ". $WALLY/bin/installation/activate-tools.sh" && \
    # bash -c ". $WALLY/bin/installation/riscv-gnu-toolchain-install.sh" && \
    bash -c ". $WALLY/bin/installation/elf2hex-install.sh" && \
    bash -c ". $WALLY/bin/installation/qemu-install.sh" && \
    bash -c ". $WALLY/bin/installation/spike-install.sh" && \
    # bash -c ". $WALLY/bin/installation/sail-install.sh" && \
    bash -c ". $WALLY/bin/installation/verilator-install.sh" && \
    cd .. && rm -rf cvw


# FROM docker.io/verilator/verilator:v5.028 AS labs344
# ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

# # hadolint ignore=DL3008
# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
#     export DEBIAN_FRONTEND=noninteractive && \
#     apt-get update -qq && \
#     apt-get install -qqy --no-install-recommends \
#         sudo \
#         git \
#         wget \
#         gnupg2 \
#         ca-certificates \
#         openssh-client \
#     && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# # hadolint ignore=DL3008
# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
#     export DEBIAN_FRONTEND=noninteractive && \
#     apt-get update -qq && \
#     apt-get install -qqy --no-install-recommends \
#         gcc-riscv64-unknown-elf \
#         binutils-riscv64-unknown-elf \
#     && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# COPY --from=whisper-builder /opt/VeeR-ISS/whisper /usr/local/bin/whisper

# # hadolint ignore=DL3008
# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
#     export DEBIAN_FRONTEND=noninteractive && \
#     apt-get update -qq && \
#     apt-get install -qqy --no-install-recommends \
#         make \
#         ninja-build \
#         libjson-perl \
#         libbit-vector-perl \
#         python3-minimal \
#         python3-pip \
#     && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
#     export DEBIAN_FRONTEND=noninteractive && \
#     apt-get update -qq && \
#     apt-get install -qqy --no-install-recommends \
#         gtkwave \
#         dbus-x11 \
#         libgtk-3-0 \
#         pop-gtk-theme \
#     && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# RUN groupadd bouncmpe -g 1000 && \
#     useradd -ms /bin/bash bouncmpe -g bouncmpe -u 1000 && \
#     printf "bouncmpe ALL= NOPASSWD: ALL\\n" >> /etc/sudoers

# ENV LC_ALL=C.UTF-8
# ENV LANG=C.UTF-8
# ENV LANGUAGE=C.UTF-8
# ENV GTK_THEME=Pop

# USER bouncmpe
# WORKDIR /home/bouncmpe

# # hadolint ignore=DL3013
# RUN python3 -m pip install --no-cache-dir --user meson numpy pandas matplotlib

# RUN git clone --depth=1 --recurse-submodules --shallow-submodules \
#         https://github.com/chipsalliance/Cores-VeeR-EL2.git /home/bouncmpe/cores/VeerEL2 &&\
#     git clone --depth=1 --recurse-submodules --shallow-submodules \
#         https://github.com/chipsalliance/Cores-VeeR-EH1.git /home/bouncmpe/cores/VeerEH1

# ENTRYPOINT ["/bin/bash"]
