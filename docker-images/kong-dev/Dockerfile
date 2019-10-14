FROM ubuntu:bionic

RUN apt-get update

RUN apt-get -y install \
        automake \
        build-essential \
        curl \
        docker \
        docker-compose \
        git \
        libpcre3 \
        libyaml-dev \
        m4 \
        openssl \
        perl \
        procps \
        unzip \
        zlib1g-dev \
        net-tools \
        htop \
        vim \
        iputils-ping

RUN git clone https://github.com/kong/openresty-build-tools

WORKDIR openresty-build-tools

RUN ./kong-ngx-build -p build \
            --openresty 1.15.8.2 \
            --openssl 1.1.1d \
            --luarocks 3.2.1 \
            --pcre 8.43


ENV PATH=/openresty-build-tools/build/openresty/bin:/openresty-build-tools/build/openresty/nginx/sbin:/openresty-build-tools/build/luarocks/bin:$PATH
ENV OPENSSL_DIR=/openresty-build-tools/build/openssl


WORKDIR /
ENV KONG_ROOT=/kong
RUN git clone https://github.com/Kong/kong.git
RUN cd kong && git checkout next && make dev


RUN luarocks install lua-resty-kafka 0.07
RUN luarocks path --bin >> ~/.bashrc

RUN sed -i "s#export LUA_PATH='/#export LUA_PATH='$KONG_ROOT/?.lua;/#" ~/.bashrc

RUN mkdir -p /workspace
WORKDIR /workspace