ARG LABS344_RHEL_BASE_IMAGE=ghcr.io/almalinux/almalinux
ARG LABS344_RHEL_VERSION=9

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

FROM labs344-builder AS labs344-toolchain
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

FROM labs344-builder AS labs344-tools
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

FROM ${LABS344_RHEL_BASE_IMAGE}:${LABS344_RHEL_VERSION} AS labs344
ARG TARGETARCH TARGETOS TARGETPLATFORM TARGETVARIANT

COPY --from=labs344-toolchain /opt/riscv /opt/riscv
