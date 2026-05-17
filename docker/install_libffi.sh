#!/bin/bash
set -xeo pipefail

LIBFFI_VERSION="3.5.2"
LIBFFI_SHA256="f3a3082a23b37c293a4fcd1053147b371f2ff91fa7ea1b2a52e335676bac82dc"

curl -sS -L "https://github.com/libffi/libffi/releases/download/v${LIBFFI_VERSION}/libffi-${LIBFFI_VERSION}.tar.gz" \
    -o libffi-${LIBFFI_VERSION}.tar.gz
echo "${LIBFFI_SHA256}  libffi-${LIBFFI_VERSION}.tar.gz" | sha256sum -c -
tar zxf libffi-${LIBFFI_VERSION}.tar.gz
rm libffi-${LIBFFI_VERSION}.tar.gz
pushd libffi-${LIBFFI_VERSION}
STACK_PROTECTOR_FLAGS="-fstack-protector-strong"
if [ "$1" == "m32" ]; then
  setarch i386 ./configure --prefix=/usr/local CFLAGS="-m32 -g -O2 $STACK_PROTECTOR_FLAGS -Wformat -Werror=format-security"
else
  ./configure --prefix=/usr/local CFLAGS="-g -O2 $STACK_PROTECTOR_FLAGS -fPIC -Wformat -Werror=format-security"
fi
make install
popd
rm -rf libffi-${LIBFFI_VERSION}
