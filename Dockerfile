FROM ubuntu:22.04

WORKDIR /work

RUN apt-get update \
  && apt-get install -y build-essential cmake git python3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV HOST 0.0.0.0
EXPOSE 6931
