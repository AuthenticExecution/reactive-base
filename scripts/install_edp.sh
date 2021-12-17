#!/bin/bash

set -eux

# add target
rustup default $1
rustup target add x86_64-fortanix-unknown-sgx --toolchain $1

# Install utilities
cargo install fortanix-sgx-tools sgxs-tools

# Configure Cargo integration with EDP
mkdir -p $HOME/.cargo
echo -e '[target.x86_64-fortanix-unknown-sgx]\nrunner = "ftxsgx-runner-cargo"' >> $HOME/.cargo/config
