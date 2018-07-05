#!/bin/bash

set -eE
set -o pipefail
set -x 

if [ "${TRAVIS_BRANCH}" == "master" ] ; then
    echo "On \`master' branch - generating compatability matrix and pushing to Wiki."
    TMPDR="$(mktemp -d)"
    
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name  "Travis CI"
    
    git clone "https://${GH_TOKEN}@github.com/madworx/docshell.wiki.git" "${TMPDR}"

    cp ../README.md "${TMPDR}/Home.md"
    make -s generate-report DIR=$DIR > "${TMPDR}/Compatibility-matrix.md"
    cd "${TMPDR}"
    
    git commit -m 'Automated generation of compatability matrix' Compatibility-matrix.md Home.md
    git push
else
    echo "Not on \`master' branch - not publishing, only printing."
    make -s generate-report DIR=$DIR
fi
