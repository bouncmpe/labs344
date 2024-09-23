FROM docker.io/library/ubuntu:22.04 AS whisper-builder
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

# hadolint ignore=DL3008
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
# hadolint ignore=SC2046
# hadolint ignore=DL3003
RUN git clone https://github.com/chipsalliance/VeeR-ISS && \
    cd /VeeR-ISS && \
    git fetch origin pull/36/head:fix-cross-compile && \
    git switch fix-cross-compile && \
    make -j$(nproc) \
        SOFT_FLOAT=1 \
        BOOST_DIR=/usr/include/boost && \
    mkdir -p /opt/VeeR-ISS && \
    make install INSTALL_DIR=/opt/VeeR-ISS

FROM docker.io/verilator/verilator:v5.028 AS verilator
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
        sudo \
        git \
        wget \
        gnupg2 \
        ca-certificates \
        openssh-client \
    && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
        gcc-riscv64-unknown-elf \
        binutils-riscv64-unknown-elf \
    && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

COPY --from=whisper-builder /opt/VeeR-ISS/whisper /usr/local/bin/whisper

# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
        make \
        ninja-build \
        libjson-perl \
        libbit-vector-perl \
        python3-minimal \
        python3-pip \
    && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${TARGETPLATFORM}/var/cache/apt \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
        gtkwave \
        dbus-x11 \
        libgtk-3-0 \
        pop-gtk-theme \
    && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

RUN groupadd bouncmpe -g 1000 && \
    useradd -ms /bin/bash bouncmpe -g bouncmpe -u 1000 && \
    printf "bouncmpe ALL= NOPASSWD: ALL\\n" >> /etc/sudoers

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV GTK_THEME=Pop

USER bouncmpe
WORKDIR /home/bouncmpe

# hadolint ignore=DL3013
RUN python3 -m pip install --no-cache-dir --user meson numpy pandas matplotlib

ENV RV_ROOT=/home/bouncmpe/Cores-VeeR-EL2
ENV RV_BUILD_DIR=/home/bouncmpe/Cores-VeeR-EL2

ENV LABS_SRC_DIR=/home/bouncmpe/labs344
ENV LABS_BUILD_DIR=/home/bouncmpe/labs344/build

RUN git clone --depth=1 --recurse-submodules --shallow-submodules \
        https://github.com/chipsalliance/Cores-VeeR-EL2.git ${RV_ROOT}
