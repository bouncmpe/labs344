ARG LABS344_VERSION=latest
ARG LABS344_DEBIAN_VERSION=12
ARG LABS344_IMAGE_REGISTRY=localhost
ARG LABS344_IMAGE_REGISTRY_REMOTE=${LABS344_IMAGE_REGISTRY}
ARG LABS344_IMAGE_NAME=labs344
ARG LABS344_IMAGE_NAME_FULL=${LABS344_IMAGE_REGISTRY}/${LABS344_IMAGE_NAME}
ARG LABS344_IMAGE_VERSION=${LABS344_VERSION}
ARG LABS344_BUILDER_IMAGE=${LABS344_IMAGE_NAME_FULL}:${LABS344_IMAGE_VERSION}-builder
ARG LABS344_DEVEL_IMAGE=${LABS344_IMAGE_NAME_FULL}:${LABS344_IMAGE_VERSION}-devel

FROM docker.io/library/debian:${LABS344_DEBIAN_VERSION} AS labs344-builder
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

# hadolint ignore=DL3008
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
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN git clone https://github.com/openhwgroup/cvw \
    && cd cvw \
    && git checkout main \
    && git submodule update --init --recursive \
    && bash ./bin/installation/riscv-gnu-toolchain-install.sh \
    && cd .. && rm -rf cvw

FROM ${LABS344_BUILDER_IMAGE} AS labs344-devel
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

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
