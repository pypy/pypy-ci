#!/bin/bash
set -xeo pipefail

# zlib-ng built in zlib-compat mode: a drop-in replacement for zlib (same API/ABI,
# libz.so.1) with SIMD-accelerated deflate/inflate/crc32. Installed into /usr/local
# so it shadows the system zlib when PyPy is translated (PYPY_LOCALBASE=/usr/local).
ZLIB_NG_VERSION="2.3.3"
ZLIB_NG_SHA256="f9c65aa9c852eb8255b636fd9f07ce1c406f061ec19a2e7d508b318ca0c907d1"

curl -sS -L "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/${ZLIB_NG_VERSION}.tar.gz" \
    -o zlib-ng-${ZLIB_NG_VERSION}.tar.gz
echo "${ZLIB_NG_SHA256}  zlib-ng-${ZLIB_NG_VERSION}.tar.gz" | sha256sum -c -
tar zxf zlib-ng-${ZLIB_NG_VERSION}.tar.gz
rm zlib-ng-${ZLIB_NG_VERSION}.tar.gz
pushd zlib-ng-${ZLIB_NG_VERSION}

CONFIGURE_PRE="--zlib-compat --prefix=/usr/local --libdir=/usr/local/lib"
if [ "$1" == "m32" ]; then
  CFLAGS="-m32 -O2 -fPIC" setarch i386 ./configure ${CONFIGURE_PRE} --32
else
  CFLAGS="-O2 -fPIC" ./configure ${CONFIGURE_PRE}
fi
make -j4
make test
make install

popd
rm -rf zlib-ng-${ZLIB_NG_VERSION}
