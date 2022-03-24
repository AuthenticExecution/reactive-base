#!/bin/bash

set -eux

function make_repo() {
  cd $1
  mkdir build
  cd build
  cmake .. -DSECURITY=$2 -DMASTER_KEY=$3
  make install
  cd ..
  cd ..
}

git clone https://github.com/sancus-tee/sancus-main.git
cd sancus-main
make install clean SANCUS_SECURITY=$1 SANCUS_KEY=$2

cd ..

# patch sancus-support due to Riot bugs
# TODO remove this as soon as the bug is fixed
git clone https://github.com/AuthenticExecution/sancus-support.git
make_repo "sancus-support" $1 $2
