#!/bin/bash

source $(dirname ${0})/lib.sh

SBCL_VERSION=${1}
LIBFIXPOSIX_VERSION=${2}
OPENSSL_VERSION=${3}
REVISION=${4}

git config --global --add safe.directory "${GITHUB_WORKSPACE}"
git config user.name "Stelian Ionescu"
git config user.email "sionescu@cddr.org"

RELEASE="${SBCL_VERSION}+r${REVISION}"
TAG="v${RELEASE}"
git tag -m "Release ${RELEASE}" ${TAG}
git push --tags

cat > notes.md << EOF
# Components:
 - SBCL ${SBCL_VERSION}
 - libfixposix ${LIBFIXPOSIX_VERSION}
 - OpenSSL ${OPENSSL_VERSION}
EOF
gh release create \
   ${TAG} \
   --latest \
   --title "SBCL ${RELEASE}" \
   --notes-file notes.md \
   "sbcl-${RELEASE}-source.tar.bz2" \
   "sbcl-${RELEASE}-x86-64-linux-binary.tar.bz2"
