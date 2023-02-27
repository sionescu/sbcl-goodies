#!/bin/bash

if [[ -n ${RUNNER_DEBUG} ]]; then
    set -x
    echo "======== Start Environment ==========="
    env
    echo "========  End Environment  ==========="
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
