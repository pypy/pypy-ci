#!/bin/bash
set -xeo pipefail

OPENSSL_URL="https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1s/"
OPENSSL_NAME="openssl-1.1.1s"
OPENSSL_SHA256="c5ac01e760ee6ff0dab61d6b2bbd30146724d063eb322180c6f18a6f74e4b6aa"

function check_sha256sum {
    local fname=$1
    local sha256=$2
    echo "${sha256}  ${fname}" > "${fname}.sha256"
    sha256sum -c "${fname}.sha256"
    rm "${fname}.sha256"
}

echo args are $1 $2

curl -sSL -#O "${OPENSSL_URL}/${OPENSSL_NAME}.tar.gz"
check_sha256sum ${OPENSSL_NAME}.tar.gz ${OPENSSL_SHA256}
tar zxf ${OPENSSL_NAME}.tar.gz
PATH=/opt/perl/bin:$PATH
pushd ${OPENSSL_NAME}
if [ "$2" == "m32" ]; then
  setarch i386 ./Configure no-comp no-shared no-dynamic-engine -m32 linux-generic32 --prefix=/usr/local --openssldir=/usr/local
else
  ./config no-comp enable-ec_nistp_64_gcc_128 no-shared no-dynamic-engine --prefix=/usr/local --openssldir=/usr/local
fi
make depend
make -j4
# avoid installing the docs
# https://github.com/openssl/openssl/issues/6685#issuecomment-403838728
make install_sw install_ssldirs
popd
rm -rf openssl*
