FROM ubuntu:20.04 as builder

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    git \
    build-essential \
    libboost-all-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN git clone --depth=1 https://github.com/chipsalliance/VeeR-ISS

RUN cd /VeeR-ISS \
    && make -j$(nproc) \
        SOFT_FLOAT=0 \
        BOOST_DIR=/usr/include/boost \
    && mkdir -p /opt/VeeR-ISS \
    && make install INSTALL_DIR=/opt/VeeR-ISS

FROM ubuntu:20.04
COPY --from=builder /opt/VeeR-ISS /opt/VeeR-ISS
