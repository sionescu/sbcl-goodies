#!/bin/bash

source $(dirname ${0})/lib.sh

CUSTOM_LIBDIR=${1}; shift
if [[ ! -d "${CUSTOM_LIBDIR}" ]]; then
    die "Directory does not exist: CUSTOM_LIBDIR=${CUSTOM_LIBDIR}"
fi

cd libfixposix

autoreconf -f -i
./configure --enable-tests --enable-static

make -j4
make -j4 check

make install DESTDIR="${GITHUB_WORKSPACE}/destdir"
cp "${GITHUB_WORKSPACE}/destdir/usr/local/lib/libfixposix.a" "${CUSTOM_LIBDIR}/"
