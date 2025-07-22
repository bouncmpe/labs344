FROM docker.io/library/debian:${LABS344_DEBIAN_VERSION} AS labs344-builder
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

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



FROM quay.io/almalinux/almalinux:9 AS labs344-toolchain
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

RUN git clone --recurse-submodules https://github.com/openhwgroup/cvw /tmp/cvw && \
    cd /tmp/cvw && \
    git checkout main && \
    export WALLY=$(pwd) && \
    export RISCV=/opt/riscv && \
    export PYTHON_VERSION=python3.12 && \
    bash -c ". $WALLY/bin/wally-tool-chain-install.sh --clean" && \
    cd .. && rm -rf /tmp/cvw && \
    dnf clean all

COPY --from=labs344-cvw-builder /opt/riscv /opt/riscv