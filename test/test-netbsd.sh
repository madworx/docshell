#!/usr/pkg/bin/bash

SHELLS="bash dash mksh posh pdksh zsh"

. /etc/profile

for SHL in ${SHELLS} ; do
    /usr/sbin/pkg_add ${SHL} >/dev/null 2>&1 && (
        /usr/pkg/bin/${SHL} /docshell/example.sh -n 20 -l /proc --help > /tmp/tmp.output 2>&1
        STATUS="$?"
        SHLVER="$(/usr/sbin/pkg_info -X "${SHL}" | sed -n "s#^PKGNAME=##p" | sed "s#-#:#" )"
        echo "${STATUS} $(uname -s):$(uname -r) ${SHLVER}"
        sed "s/^/# /" /tmp/tmp.output
        rm /tmp/tmp.output
        echo "" ) ;
done
