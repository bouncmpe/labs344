FROM bouncmpe/rv32imc as builder

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    git \    
    autoconf automake autotools-dev \
    build-essential \
    libtool \ 
    libusb-1.* \
    pkg-config \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN git clone https://github.com/riscv/riscv-openocd.git

RUN cd riscv-openocd \
    && ./bootstrap \
    && ./configure --prefix=/opt/riscv --program-prefix=riscv- --enable-ftdi --enable-jtag_vpi \
    && make \
    && make install

FROM ubuntu:20.04 
COPY --from=builder /opt/riscv /opt/riscv

