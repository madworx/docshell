#!/usr/bin/env bash

SHELLS="bash dash ksh loksh mksh pdksh posh yash zsh"
ARGS="-n 20 -l /proc --help"

set -eE

# shellcheck disable=SC1090
. "$(dirname "$0")/test-common.sh"

if [ -n "$1" ] ; then
    SUGGESTED_OS="$1"
fi

identify_os "${SUGGESTED_OS}"

SCRIPT="${2:-/docshell/example.sh}"

for SHL in ${SHELLS} ; do
    shell_install "${SHL}" && (
        EXIT_CODE=0
        # shellcheck disable=SC2086
        "${SHL}" "${SCRIPT}" ${ARGS} \
                 > /tmp/tmp.output 2>&1 \
            || EXIT_CODE=$? && true
        echo "${EXIT_CODE} $(os_name):$(os_release) ${SHL%%-*}:$(shell_version "${SHL}")"
        sed "s/^/# /" /tmp/tmp.output
        rm -f /tmp/tmp.output || true
        echo ""
    )
done

exit 0
