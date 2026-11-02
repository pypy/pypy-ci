#!/bin/bash
# Download, verify and install a PyPy2.7 binary for translation and testing.
#
# Usage: install_pypy.sh <arch>   where <arch> is linux64, aarch64 or linux32
#
# Checksums are at https://pypy.org/checksums
set -xeo pipefail

PYPY_VERSION="8.0.1"
ARCH="${1:-linux64}"

case "${ARCH}" in
  linux64) PYPY_SHA256="78674cdf95eb4cb1dd5a9b68a70200387111cb29467f8a472ab7cf07a251653c" ;;
  aarch64) PYPY_SHA256="abd5bd601fc5af143a80d02c52b5f098f0096f9b0793140353e5e3d439676b85" ;;
  linux32) PYPY_SHA256="956365de00b86c4741acd719caff28edf3df2306962f7767ca0e2c9a73e262e5" ;;
  *) echo "unknown arch '${ARCH}', expected linux64, aarch64 or linux32"; exit 1 ;;
esac

PYPY_NAME="pypy2.7-v${PYPY_VERSION}-${ARCH}"
PYPY_TARBALL="${PYPY_NAME}.tar.gz"

wget -q "https://downloads.python.org/pypy/${PYPY_TARBALL}" -O "${PYPY_TARBALL}"
echo "${PYPY_SHA256}  ${PYPY_TARBALL}" | sha256sum -c -
tar -C /opt -xzf "${PYPY_TARBALL}"
rm "${PYPY_TARBALL}"

# make sure the unprivileged buildworker user can read and traverse the install
chmod -R a+r "/opt/${PYPY_NAME}"
chmod -R a+X "/opt/${PYPY_NAME}"

ln -s "/opt/${PYPY_NAME}/bin/pypy" /usr/local/bin/pypy
ln -s "/opt/${PYPY_NAME}/bin/pypy" /usr/local/bin/python

pypy -mensurepip
pypy -mpip install --upgrade pip==20.3.4
pypy -mpip install --upgrade setuptools wheel
