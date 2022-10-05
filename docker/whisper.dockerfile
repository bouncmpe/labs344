ARG TARGETARCH=amd64

FROM $TARGETARCH/ubuntu:20.04 as builder

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    git \
    build-essential \
    libboost-all-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN git clone --depth=1 https://github.com/chipsalliance/SweRV-ISS

RUN cd /SweRV-ISS \
    && make -j$(nproc) BOOST_DIR=/usr/include/boost 

RUN cd /SweRV-ISS \
    && mkdir -p /opt/SweRV-ISS \
    && make install INSTALL_DIR=/opt/SweRV-ISS

FROM $TARGETARCH/ubuntu:20.04
COPY --from=builder /opt/SweRV-ISS /opt/SweRV-ISS
