FROM ubuntu:18.04

WORKDIR /usr/src/install

## Python ##
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl python3.6 python3-distutils git make \
    && echo -e '#!/bin/bash\npython3.6 "$@"' > /usr/bin/python && chmod +x /usr/bin/python \
    && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python get-pip.py

## Rust ##
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

COPY scripts/install_rust.sh .
RUN ./install_rust.sh

## EDP ##
COPY scripts/install_edp.sh .
RUN ./install_edp.sh

## Sancus ##
ENV PYTHONPATH=\$PYTHONPATH:/usr/local/share/sancus-compiler/python/lib/
ARG SANCUS_SECURITY=128
ARG SANCUS_KEY=deadbeefcafebabec0defeeddefec8ed

COPY scripts/install_sancus.sh .
RUN ./install_sancus.sh $SANCUS_SECURITY $SANCUS_KEY

## SGX attestation stuff ##
COPY exec/sgx-attester /bin/
RUN apt-get update && apt-get install -y --no-install-recommends clang gcc-multilib

## TrustZone ##
WORKDIR /optee

ENV PATH=$PATH:/optee/toolchains/aarch32/bin:/optee/toolchains/aarch64/bin \
    OPTEE_OS=/optee/optee_os \
    OPTEE_CLIENT=/optee/optee_client

COPY scripts/install_trustzone.sh .
RUN ./install_trustzone.sh

## Attestation Manager stuff ##
COPY exec/attman-cli /bin/

# Cleanup
RUN rm -rf /usr/src/install && rm /optee/install_trustzone.sh
WORKDIR /usr/src/app
