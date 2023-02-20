#!/bin/bash

if [[ -n ${RUNNER_DEBUG} ]]; then
    set -x
fi

set -Eeuo pipefail

function die() {
    echo "${@}" >&2
    exit 1
}

function join() {
  local sep="${1}" ; shift
  local first="${1}" ; shift
  printf "%s" "${first}" "${@/#/${sep}}"
}

function new_dep() {
    local dep=${1}
    local ver=${2}
    echo "New ${dep} version ${ver}"
    notes+=("${dep} ${ver}")
}

new_sbcl=
new_deps=
declare -a notes

LATEST_SBCL=$(gh release list -R sbcl/sbcl -L 1 \
                  | perl -n -e'/Latest\W+sbcl-([.0-9]+)/ && print $1')
if [[ ${LATEST_SBCL} != ${SBCL_VERSION} ]]; then
    new_sbcl=true
    new_dep "SBCL" "${LATEST_SBCL}"
    sed -i "/SBCL_VERSION=/c\\SBCL_VERSION=${LATEST_SBCL}" build.env
fi

LATEST_LIBFIXPOSIX=$(gh release list -R sionescu/libfixposix -L 1 \
                         | perl -n -e'/Latest\W+v([.0-9]+)/ && print $1')
if [[ ${LATEST_LIBFIXPOSIX} != ${LIBFIXPOSIX_VERSION} ]]; then
    new_deps=true
    new_dep "libfixposix" "${LATEST_LIBFIXPOSIX}"
    sed -i "/LIBFIXPOSIX_VERSION=/c\\LIBFIXPOSIX_VERSION=${LATEST_LIBFIXPOSIX}" build.env
fi

LATEST_OPENSSL=$(dpkg-query --show --showformat='${Version}' libssl-dev)
if [[ ${LATEST_OPENSSL} != ${OPENSSL_VERSION} ]]; then
    new_deps=true
    new_dep "OpenSSL" "${LATEST_OPENSSL}"
    sed -i "/OPENSSL_VERSION=/c\\OPENSSL_VERSION=${LATEST_OPENSSL}" build.env
fi

if [[ ${new_deps} ]]; then
    if [[ ${REVISION} == 99 ]]; then
        die "Already at revision 99. Something's wrong."
    fi
    echo "Bumping revision to ${REVISION}"
    REVISION=$(printf '%02d' $(( REVISION + 1 )))
fi
if [[ ${new_sbcl} ]]; then
    echo "Resetting revision to 00"
    REVISION="00"
fi
sed -i "/REVISION=/c\\REVISION=${REVISION}" build.env

git config user.name "Stelian Ionescu"
git config user.email "sionescu@cddr.org"
if [[ ${new_sbcl} || ${new_deps} ]]; then
    MSG=$(join ", " "${notes[@]}")
    new_branch=new_deps_$(date -u +%Y%m%dT%H%M)
    git checkout -b "${new_branch}"
    git add build.env
    git commit -a -m "${MSG}"
    git push origin "${new_branch}:"${new_branch}
    gh pr create -B master -H "${new_branch}" \
       --title "${MSG}" --body "Automatically created by Gihub action"
else
    echo "No new deps detected."
fi
