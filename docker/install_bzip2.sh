#!/bin/bash
set -xeo pipefail

BZIP2_VERSION="1.0.8"

function check_sha512sum {
    local fname=$1
    local sha512=$2
    echo "${sha512}  ${fname}" > "${fname}.sha512"
    sha512sum -c "${fname}.sha512"
    rm "${fname}.sha512"
}

wget --no-check-certificate https://sourceware.org/pub/bzip2/bzip2-${BZIP2_VERSION}.tar.gz
SHA512="083f5e675d73f3233c7930ebe20425a533feedeaaa9d8cc86831312a6581cefbe6ed0d08d2fa89be81082f2a5abdabca8b3c080bf97218a1bd59dc118a30b9f3"

tar zxf bzip2*.tar.gz
rm bzip2*.tar.gz*
pushd bzip2*
CFLAGS="-fPIC ${CFLAGS}"
if [ "$1" == "m32" ]; then
  CFLAGS="-m32 ${CFLAGS}"
  setarch i386 make -f Makefile-libbz2_so
else
  make -f Makefile-libbz2_so
fi
make install
cp -r libbz2.so* /usr/local/lib
popd
rm -rf bzip2*
