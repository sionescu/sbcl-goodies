#!/bin/bash

source $(dirname ${0})/lib.sh

SBCL_HOST_VERSION=${1}; shift
if [[ -z "${SBCL_HOST_VERSION}" ]]; then
    die "Argument SBCL_HOST_VERSION is empty, expecting a valid version"
fi

SRCDIR=sbcl-${SBCL_HOST_VERSION}-x86-64-linux
TARBALL=${SRCDIR}-binary.tar.bz2

wget https://pilotfiber.dl.sourceforge.net/project/sbcl/sbcl/${SBCL_HOST_VERSION}/${TARBALL}
tar x -f ${TARBALL}

ln -sfv ${SRCDIR} sbcl-host
echo "Unpacked SBCL host to ${PWD}/sbcl-host"
echo SBCL_HOST="${GITHUB_WORKSPACE}/sbcl-host" >> ${GITHUB_ENV}
