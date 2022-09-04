FROM ghcr.io/bouncmpe/riscv as riscv
FROM ghcr.io/bouncmpe/whisper as whisper

FROM ubuntu:20.04

COPY --from=riscv /opt/riscv /opt/riscv
COPY --from=whisper /opt/SweRV-ISS /opt/SweRV-ISS/bin

# Graphical apps (gtk) complain if we don't set these variables
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    git \
    curl \
    build-essential \
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

## Test graphical apps -- xeyes, xcalc
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    x11-apps \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN groupadd students -g 1000 \
    && useradd -ms /bin/bash bouncmpe -g 1000 -u 1000 

USER bouncmpe

ENV PATH=$PATH:/opt/riscv/bin:/opt/SweRV-ISS/bin

