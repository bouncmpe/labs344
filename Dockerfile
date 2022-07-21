FROM bouncmpe/rv32imc as rv32imc
FROM bouncmpe/whisper as whisper

FROM ubuntu:20.04 

COPY --from=rv32imc /opt/riscv /opt/riscv
COPY --from=whisper /opt/SweRV-ISS /opt/SweRV-ISS/bin

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    sudo \
    git \
    curl \
    build-essential \
    python3 \
    python3-venv \
    python-is-python3 \
    verilator \
    gtkwave \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN groupadd work -g 1000 \
    && useradd -ms /bin/bash bouncmpe -g 1000 -u 1000 \
    && printf "bouncmpe:bouncmpe" | chpasswd \
    && printf "bouncmpe ALL= NOPASSWD: ALL\\n" >> /etc/sudoers

USER bouncmpe

ENV PATH=$PATH:/opt/riscv/bin:/opt/SweRV-ISS/bin