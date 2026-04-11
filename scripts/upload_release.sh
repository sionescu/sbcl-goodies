#!/bin/bash

source $(dirname ${0})/lib.sh

SBCL_VERSION=${1}
ASDF_VERSION=${2}
REVISION=${3}
LIBFIXPOSIX_VERSION=${4}
OPENSSL_VERSION=${5}
LIBTLS_VERSION=${6}

git config --global --add safe.directory "${GITHUB_WORKSPACE}"
git config user.name "Stelian Ionescu"
git config user.email "sionescu@cddr.org"

RELEASE="${SBCL_VERSION}+r${REVISION}"
TAG="v${RELEASE}"

TAG_EXISTS=$(git ls-remote --tags origin "refs/tags/$TAG" | wc -l)
# RELEASE_EXISTS=$({ gh release view "$TAG" &>/dev/null && echo 1 ; } || echo 0)

if [ "$TAG_EXISTS" -eq 0 ]; then
    git tag -m "Release ${RELEASE}" ${TAG}
    git push --tags

    cat >> notes.md << EOF
# Components (${OS}):
 - SBCL ${SBCL_VERSION}
 - ASDF ${ASDF_VERSION}
 - libfixposix ${LIBFIXPOSIX_VERSION}
 - OpenSSL ${OPENSSL_VERSION}
 - LibTLS ${LIBTLS_VERSION}
EOF
    gh release create \
       ${TAG} \
       --latest \
       --title "SBCL ${RELEASE}" \
       --notes-file notes.md \
       "sbcl-${RELEASE}-source.tar.bz2"
fi

gh release upload ${TAG} "sbcl-${RELEASE}-$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')-binary.tar.bz2"
