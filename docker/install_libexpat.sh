#!/bin/bash
set -xeo pipefail

EXPAT_VERSION="2.8.1"
EXPAT_SHA256="a52eb72108be160e190b5cafa5bba8663f1313f2013e26060d1c18e26e31067b"

curl -sS -L "https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION//./_}/expat-${EXPAT_VERSION}.tar.gz" \
    -o expat-${EXPAT_VERSION}.tar.gz
echo "${EXPAT_SHA256}  expat-${EXPAT_VERSION}.tar.gz" | sha256sum -c -
tar zxf expat-${EXPAT_VERSION}.tar.gz
rm expat-${EXPAT_VERSION}.tar.gz
pushd expat-${EXPAT_VERSION}
CONFIGURE_PRE="--prefix=/usr/local --enable-shared=yes --enable-static=yes --disable-dependency-tracking"
CFLAGS="-fPIC ${CFLAGS}"
if [ "$1" == "m32" ]; then
  setarch i386 ./configure ${CONFIGURE_PRE} CFLAGS="-m32 ${CFLAGS}"
else
  ./configure ${CONFIGURE_PRE} CFLAGS="${CFLAGS}"
fi
make install
popd
rm -rf expat-${EXPAT_VERSION}
