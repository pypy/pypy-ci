#!/bin/bash
set -xeo pipefail

mkdir ncurses
pushd ncurses
# Let's encrypt's certificate expired Sept 2021, it is difficult to update on
# centos6. When we move to centos7, remove the --no-check-certificate
wget -q --no-check-certificate https://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz
tar -xf ncurses-6.1.tar.gz --strip-components=1
./configure --prefix=/usr/local --enable-widec --enable-pc-files --without-tests --without-cxx --with-termlib --without-normal --with-shared --enable-database --with-terminfo-dirs=/lib/terminfo:/usr/share/terminfo
echo "#define NCURSES_USE_DATABASE 1" >> include/ncurses_cfg.h
make -j4
make install
popd
rm -rf  ncurses
