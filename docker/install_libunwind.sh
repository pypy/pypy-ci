#!/bin/bash
set -xeo pipefail

git clone --depth 1 --branch v1.8.1 https://github.com/libunwind/libunwind

pushd libunwind

autoreconf -i; ./configure --prefix=/usr/local
make -j && make install

popd
