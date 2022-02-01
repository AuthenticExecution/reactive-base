#!/bin/bash

set -eux

OPTEE_VERSION=3.15.0

# toolchain
git clone --branch $OPTEE_VERSION https://github.com/OP-TEE/build.git
(cd build && make -f toolchain.mk -j2)

# optee_os
git clone --branch $OPTEE_VERSION https://github.com/OP-TEE/optee_os
(cd optee_os && make \
  CFG_TEE_BENCHMARK=n \
  CFG_TEE_CORE_LOG_LEVEL=3 \
  CROSS_COMPILE=arm-linux-gnueabihf- \
  CROSS_COMPILE_core=arm-linux-gnueabihf- \
  CROSS_COMPILE_ta_arm32=arm-linux-gnueabihf- \
  CROSS_COMPILE_ta_arm64=aarch64-linux-gnu- \
  DEBUG=1 \
  O=out/arm \
  PLATFORM=vexpress-qemu_virt)

# optee_client
git clone --branch $OPTEE_VERSION https://github.com/OP-TEE/optee_client
(cd optee_client && mkdir build && cd build \
  && cmake -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_INSTALL_PREFIX=../out/export/usr .. \
  && make && make install)

# optee_examples
git clone --branch $OPTEE_VERSION https://github.com/linaro-swg/optee_examples.git
