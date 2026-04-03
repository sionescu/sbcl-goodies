#!/bin/bash

source $(dirname ${0})/lib.sh

SBCL_HOST=${1}
SBCL_VERSION=${2}
ASDF_VERSION=${3}
REVISION=${4}
export CUSTOM_LIBDIR=${5}
if [[ ! -d "${CUSTOM_LIBDIR}" ]]; then
    die "Directory does not exist: CUSTOM_LIBDIR=${CUSTOM_LIBDIR}"
fi

cd sbcl

# Prevent SBCL build from generating a version string from git
rm -rf .git
# Override SBCL lisp-implementation-version
echo "\"${SBCL_VERSION}+r${REVISION}\"" > version.lisp-expr

# Update ASDF
pushd contrib/asdf
./pull-asdf.sh "${ASDF_VERSION}"
popd

UNAME=$(uname -s)

# Link runtime with goodies and overwrite the original
if [ "$UNAME" == Linux ]; then
    export SYS_LIBDIR="/usr/lib/x86_64-linux-gnu"
    LIBZSTD=${SYS_LIBDIR}/libzstd.a
    # Quick hack, not safe for cross-compiling.
    sed -i "s:-lzstd:$LIBZSTD:" src/runtime/Config.*

    LIBFIXPOSIX=${CUSTOM_LIBDIR}/libfixposix.a
    LIBCRYPTO=${SYS_LIBDIR}/libcrypto.a
    LIBSSL=${SYS_LIBDIR}/libssl.a
    LIBTLS=${SYS_LIBDIR}/libtls.a

    export WHOLE_ARCHIVES="-Wl,--whole-archive $LIBFIXPOSIX $LIBCRYPTO $LIBSSL $LIBTLS"

elif [ "$UNAME" == Darwin ]; then
    export SYS_LIBDIR="/opt/homebrew/Cellar"
    LIBZSTD=${SYS_LIBDIR}/zstd/1.5.7_1/lib/libzstd.a
    # Quick hack, not safe for cross-compiling.
    sed -i '' "s:-lzstd:$LIBZSTD:" src/runtime/Config.*

    LIBFIXPOSIX=${CUSTOM_LIBDIR}/libfixposix.a
    LIBCRYPTO="${SYS_LIBDIR}/openssl@3/${OPENSSL_VERSION}/lib/libcrypto.a"
    LIBSSL="${SYS_LIBDIR}/openssl@3/${OPENSSL_VERSION}/lib/libssl.a"
    LIBTLS="${SYS_LIBDIR}/libretls/${LIBTLS_VERSION}/lib/libtls.a"

    # -force_load only works on one library at a time
    export WHOLE_ARCHIVES="-Wl,-force_load $LIBFIXPOSIX -Wl,-force_load $LIBCRYPTO -Wl,-force_load $LIBSSL -Wl $LIBTLS"
fi

cp ../scripts/COPYING.zstd ./

env SBCL_MAKE_PARALLEL=1 \
    SBCL_MAKE_JOBS=-j4 \
    ./make.sh --xc-host="${SBCL_HOST} --noinform --no-userinit" \
    --with-sb-core-compression \
    --with-sb-linkable-runtime \
    --without-gencgc --with-mark-region-gc \
    --without-sb-eval \
    --with-sb-fasteval

make -C src/runtime -f binaries.mk sbcl.extras
mv -vf src/runtime/sbcl.extras src/runtime/sbcl

# Include libfixposix headers
mkdir -vp third_party/include
cp -av ../destdir/usr/local/include/* third_party/include/

cd ..

# Build source distribution
SRCDIST=sbcl-${SBCL_VERSION}+r${REVISION}
mv -v sbcl "${SRCDIST}"
"${SRCDIST}"/source-distribution.sh "${SRCDIST}"
bzip2 "${SRCDIST}"-source.tar

# Build binary distribution
BINDIST="${SRCDIST}"-$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')
mv -v "${SRCDIST}" "${BINDIST}"
"${BINDIST}"/binary-distribution.sh "${BINDIST}"
bzip2 "${BINDIST}"-binary.tar

echo "###################################################"
echo "Created ${SRCDIST}-source.tar.bz2"
echo "Created ${BINDIST}-binary.tar.bz2"
echo "###################################################"
echo "SRCDIST=${SRCDIST}-source.tar.bz2" >> ${GITHUB_ENV}
echo "BINDIST=${BINDIST}-binary.tar.bz2" >> ${GITHUB_ENV}
