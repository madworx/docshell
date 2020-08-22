#!/bin/bash

REQUESTED="${1:-}"

HAS_RUN=0

# Test "regular" docker image-based OS distributions:
for VER in madworx/debian-archive:{jessie,etch,lenny,squeeze,wheezy} \
           madworx/multibash \
           debian:{buster,sid,stretch,bullseye}-slim \
           ubuntu:{artful,bionic,trusty,xenial,zesty,yakkety,precise,disco,eoan,focal} \
           centos:{7,8} \
           opensuse/{leap,tumbleweed} \
           madworx/netbsd:{7.1.2,6.1.5,8.0,8.1}-x86_64 ; do
    if [[ "${VER}" = *${REQUESTED}* ]] ; then
        HAS_RUN=1
        echo "Testing image ${VER}" 1>&2

        PP=""
        # The  madworx/netbsd images  needs to  have the  volume mount
        # prefixed by /bsd.
        if [[ "${VER}" = madworx/netbsd:* ]] ; then
            PP="/bsd"
        fi

        docker run --rm \
               -v "$(dirname "$(readlink -f "$0")")/..:${PP}/docshell" \
               -i \
               -e VER \
               "${VER}" \
               /docshell/test/test-shells.sh "${VER}"
    fi
done

# Test Alpine Linux, who has special needs:
for VER in alpine:3.{1,2,3,4,5,6,7,8,9,10} alpine:edge ; do
    if [[ "${VER}" = *${REQUESTED}* ]] ; then
        HAS_RUN=1
        echo "Testing image ${VER}" 1>&2
        docker run --rm \
               -v "$(dirname "$(readlink -f "$0")")/..:/docshell" \
               -i \
               -e VER "${VER}" \
               /bin/sh -c "apk update >/dev/null 2>&1 ; \
                           apk add bash >/dev/null 2>&1 ; \
                           /docshell/test/test-shells.sh \"${VER}\""
    fi
done

#
# Minix image currently doesn't support file system mounting, so we'll
# do a work-around for it:
#
# shellcheck disable=SC2043
for VER in madworx/minix:latest ; do
    if [[ "${VER}" = *${REQUESTED}* ]] ; then
        HAS_RUN=1
        echo "Testing image ${VER}" 1>&2
        DID=$(docker run --rm \
                     -d \
                     -i \
                     -e VER "${VER}")
        docker cp "$(dirname "$(readlink -f "$0")")/.." "${DID}:/docshell"
        # Wait until Minix is booted:
        docker exec -i "${DID}" sshexec true
        docker exec -i "${DID}" scp -qr /docshell localhost:/docshell
        docker exec -i "${DID}" ssh localhost pkgin -y install bash >/dev/null 2>&1
        docker exec -i "${DID}" ssh localhost /docshell/test/test-shells.sh "${VER}"
        docker stop "${DID}" >/dev/null
    fi
done

if [[ "osx" = *${REQUESTED}* ]] ; then
    HAS_RUN=1
    ./test-shells.sh "osx:notyetknown" ../example.sh
fi

if [ "${HAS_RUN}" == "0" ] ; then
    echo "Error: Was not able to match requested os \`${REQUESTED}' to any os/release" 1>&2
    exit 1
fi
