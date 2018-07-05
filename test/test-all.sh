#!/bin/bash

REQUESTED="${1:-}"

# Test "regular" docker image-based OS distributions:
for VER in madworx/debian-archive:{etch,lenny,squeeze} \
           debian:{buster,jessie,sid,stretch,wheezy}-slim \
           ubuntu:{artful,bionic,trusty,xenial,zesty,yakkety,precise} \
           centos:{6,7} \
           opensuse/{leap,tumbleweed} ; do
    if [[ "${VER}" = *${REQUESTED}* ]] ; then
        echo "Testing image ${VER}" 1>&2
        docker run --rm \
               -v $(dirname $(readlink -f $0))/..:/docshell \
               -i \
               -e VER \
               "${VER}" \
               /docshell/test/test-shells.sh "${VER}"
    fi
done

# Test Alpine Linux, who has special needs:
for VER in alpine:3.{1,2,3,4,5,6,7} alpine:edge ; do
    if [[ "${VER}" = *${REQUESTED}* ]] ; then
        echo "Testing image ${VER}" 1>&2
        docker run --rm \
               -v $(dirname $(readlink -f $0))/..:/docshell \
               -i \
               -e VER "${VER}" \
               /bin/sh -c "apk update >/dev/null 2>&1 ; \
                           apk add bash >/dev/null 2>&1 ; \
                           /docshell/test/test-shells.sh \"${VER}\""
    fi
done

# Test NetBSD, we need a prefix to the volume mount:
for VER in madworx/netbsd:{7.1.2,6.1.5}-x86_64 ; do
    if [[ "${VER}" = *${REQUESTED}* ]] ; then
        echo "Testing image ${VER}" 1>&2
        docker run --privileged --rm \
               -v $(dirname $(readlink -f $0))/..:/bsd/docshell \
               -i \
               -e VER \
               "${VER}" \
               /docshell/test/test-shells.sh "${VER}"
    fi
done

# Test "multibash":
if [[ "bash" = *${REQUESTED}* ]] ; then
    docker run --rm -i madworx/multibash /bin/bash -c ' \
base64 -d | tar xf - ; \
os="bash"
for SHL in /usr/local/bin/bash-* ; do
    pkgver=$(basename $SHL)
    pkgver=${pkgver#bash-}
    ${SHL} /example.sh -n 20 -l /proc --help > /tmp/tmp.output 2>&1
    STATUS=$?
    echo "${STATUS} ${os}:${pkgver} bash:${pkgver}"
    sed "s/^/# /" /tmp/tmp.output
    rm /tmp/tmp.output
    echo ""
done' < <(cd ../ ; tar cf - example.sh test/example.expect | base64)
fi