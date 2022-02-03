FROM ubuntu:18.04

ARG RUST_TOOLCHAIN=nightly-2021-12-01

WORKDIR /usr/src/install

## Non-interactive ##
RUN echo "Europe/Brussels" > /etc/timezone && apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata

## Install all needed packages ##
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl python3.6 python3-distutils git make gcc libc6-dev wget \
    gpg pkg-config libssl-dev protobuf-compiler lsb-release screen unzip \
    python3-pycryptodome gcc-multilib cmake python3-pip python3-wheel

## Python ##
RUN ln -s /usr/bin/python3 /usr/bin/python \
    && python -m pip install --upgrade pip setuptools

## Rust ##
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

COPY scripts/install_rust.sh .
RUN ./install_rust.sh $RUST_TOOLCHAIN

## EDP ##
COPY scripts/install_edp.sh .
RUN ./install_edp.sh $RUST_TOOLCHAIN

## Sancus ##
ENV PYTHONPATH=\$PYTHONPATH:/usr/local/share/sancus-compiler/python/lib/
ARG SANCUS_SECURITY=128
ARG SANCUS_KEY=deadbeefcafebabec0defeeddefec8ed

COPY scripts/install_sancus.sh .
RUN ./install_sancus.sh $SANCUS_SECURITY $SANCUS_KEY

## TrustZone ##
WORKDIR /optee

ENV PATH=$PATH:/optee/toolchains/aarch32/bin:/optee/toolchains/aarch64/bin \
    OPTEE_OS=/optee/optee_os \
    OPTEE_CLIENT=/optee/optee_client

COPY scripts/install_trustzone.sh .
RUN ./install_trustzone.sh

## Install latest cmake version ##
# This is needed for the rust_mbedtls library in order to compile
# For some reason, this version breaks the installation of Sancus, so it has
# to be installed later
COPY scripts/install_cmake.sh .
RUN ./install_cmake.sh

# Install sgx-attester and attman-cli
RUN cargo install --git https://github.com/AuthenticExecution/sgx-attester.git \
    && cargo install --git https://github.com/AuthenticExecution/attestation-manager-client.git

# Cleanup
RUN rm -rf /usr/src/install \
    && rm /optee/install_trustzone.sh \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
