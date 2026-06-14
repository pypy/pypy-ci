#!/bin/bash
set -xeo pipefail

OPENSSL_URL="https://github.com/openssl/openssl/releases/download/openssl-3.0.21"
OPENSSL_NAME="openssl-3.0.21"
OPENSSL_SHA256="617e29af8e421f46649484a4937e48c685e47f46488167c982f88bc4ec1d522f"

function check_sha256sum {
    local fname=$1
    local sha256=$2
    echo "${sha256}  ${fname}" > "${fname}.sha256"
    sha256sum -c "${fname}.sha256"
    rm "${fname}.sha256"
}

curl -sSL -#O "${OPENSSL_URL}/${OPENSSL_NAME}.tar.gz"
check_sha256sum ${OPENSSL_NAME}.tar.gz ${OPENSSL_SHA256}
tar zxf ${OPENSSL_NAME}.tar.gz
PATH=/opt/perl/bin:$PATH
pushd ${OPENSSL_NAME}
if [ "$1" == "m32" ]; then
  setarch i386 ./Configure no-comp no-shared no-dynamic-engine -m32 linux-generic32 --prefix=/usr/local --openssldir=/usr/local
else
  ./config no-comp enable-ec_nistp_64_gcc_128 no-shared no-dynamic-engine --prefix=/usr/local --openssldir=/usr/local
fi
make depend
make -j4
make install_sw install_ssldirs
popd
rm -rf openssl*
