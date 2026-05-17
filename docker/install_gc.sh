#!/bin/bash
set -xeo pipefail

mkdir boehm
pushd boehm
wget -q https://github.com/ivmai/libatomic_ops/releases/download/v7.6.10/libatomic_ops-7.6.10.tar.gz
mkdir libatomic_ops
tar -C libatomic_ops --strip-components=1 -xf libatomic_ops-7.6.10.tar.gz
wget -q https://github.com/ivmai/bdwgc/releases/download/v8.0.4/gc-8.0.4.tar.gz
mkdir bdwgc
tar -C bdwgc --strip-components=1 -xf gc-8.0.4.tar.gz
ln -s  $PWD/libatomic_ops $PWD/bdwgc/libatomic_ops
cd bdwgc
autoreconf -vif
automake --add-missing
./configure --prefix=/usr/local
make
make install
popd
rm -rf  boehm
