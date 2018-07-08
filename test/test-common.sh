#!/bin/bash

identify_os() {
    IMG="$1"
    case "${IMG}" in
        madworx/debian-archive:*) I=setup_archived_debian  ;;
        madworx/netbsd:*)         I=setup_netbsd           ;;
        madworx/multibash)        I=setup_multibash        ;;
        opensuse/*)               I=setup_opensuse         ;;
        debian:*)                 I=setup_debian           ;;
        ubuntu:*)                 I=setup_debian           ;;
        centos:*)                 I=setup_centos           ;;
        alpine:*)                 I=setup_alpine           ;;
        *) echo "Unknown OS: [${IMG}]" ; exit 1 ;;
    esac
    ${I} "${IMG}"
}

_setup_base() {
    OS_NAME="$1"
    OS_RELEASE="$2"
    
    os_name() {
        echo "${OS_NAME}"
    }
    os_release() {
        echo "${OS_RELEASE}"
    }
    volume_prefix() {
        echo ""
    }
}

setup_netbsd() {
    IMG="netbsd${1#madworx/netbsd}"
    _setup_base "${IMG%:*}" "${IMG#*:}"

    shell_install() {
        # shellcheck disable=SC1091
        . /etc/profile
        /usr/sbin/pkg_add "${SHL}" >/dev/null 2>&1 || return 1
    }
    shell_version() {
        # shellcheck disable=SC1091
        . /etc/profile
        /usr/sbin/pkg_info -X "${SHL}" | sed -n "s#^PKGNAME=##p" | sed "s#.*-##"
    }
    volume_prefix() {
        echo "/bsd"
    }
}

setup_alpine() {
    _setup_base "${1%:*}" "${1#*:}"

    shell_install() {
        apk add "${SHL}" >/dev/null 2>&1 || return 1
        # Work-around for the fact that loksh installs as /bin/ksh:
        ln -sf /bin/ksh /bin/loksh || true
    }
    shell_version() {
        apk info "${SHL}" | sed -n "1s/^${SHL}-\\([^ ]*\\) .*/\\1/p"
    }
}

setup_opensuse() {
    _setup_base "${1%/*}" "${1#*/}"

    shell_install() {
        ! zypper info "${SHL}" 2>&1 | grep -Eq '^package.*not found' && \
            zypper install -y "${SHL}" >/dev/null 2>&1
    }
    shell_version() {
        zypper info "${SHL}" | awk -F' *: *' '$1=="Version"{print $2}'
    }
}

setup_debian() {
    _setup_base "${1%:*}" "${1#*:}"
    
    # Perform best-effort update of package list.
    apt-get update >/dev/null 2>&1 || true

    shell_install() {
        apt-get -q install --force-yes -y "$1" >/dev/null 2>&1
    }
    
    shell_version() {
        dpkg-query -s "$1" | sed -n "s#^Version: ##p"
    }
}

setup_archived_debian() {
    setup_debian "debian${1#madworx/debian-archive}"
}

setup_centos() {
    _setup_base "${1%:*}" "${1#*:}"
    
    shell_install() {
        yum install -y "$1" >/dev/null 2>&1
    }
    shell_version() {
        yum info "$1" | awk -F' *: *' '$1=="Release"{print $2}'
    }
    
}

setup_multibash() {
    _setup_base bash multi

    SHELLS=""
    for F in /usr/local/bin/bash-* ; do
        SHELLS="${SHELLS} $(basename "${F}")"
    done
    
    shell_install() {
        true
    }
    shell_version() {
        echo "${1#*-}"
    }
}
