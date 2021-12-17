#!/bin/bash

set -eux

url="https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init"
wget "$url"
chmod +x rustup-init
./rustup-init -y --no-modify-path --default-toolchain $1
chmod -R a+w $RUSTUP_HOME $CARGO_HOME
