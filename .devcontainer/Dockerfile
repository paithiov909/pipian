# syntax=docker/dockerfile:1

ARG VARIANT="4"
FROM ghcr.io/rocker-org/devcontainer/r-ver:${VARIANT}

RUN apt-get -y update && export DEBIAN_FRONTEND=noninteractive && apt-get -y --no-install-recommends install \
  fonts-noto-cjk \
  fonts-ipafont-gothic \
  libmecab-dev \
  mecab \
  mecab-ipadic-utf8 && \
  apt-get autoremove -y && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone --depth 1 https://github.com/paithiov909/crfpp.git && \
  git clone --depth 1 https://github.com/paithiov909/cabocha.git && \
  cd ./crfpp && \
  ./configure && make && make install && \
  ldconfig && \
  cd ../cabocha && \
  ./configure --with-charset=UTF8 --enable-utf8-only && make && make install && \
  ldconfig

RUN rm -rf /tmp/*
