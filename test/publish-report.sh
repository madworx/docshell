#!/bin/bash

set -eE
set -o pipefail
set -x

# shellcheck disable=SC1090
source <(curl https://raw.githubusercontent.com/madworx/cd-ci-glue/master/src/cd-ci-glue.bash)

# shellcheck disable=SC2015
is_travis_master_push && (
    echo "Push event on \`master' branch. Publishing to Wiki"

    TMPDR=$(github_wiki_prepare madworx/docshell)

    # Undelete the compatability-report.tap file:
    (
        cd "${TMPDR}"
        git reset HEAD compatability-report.tap
        git checkout -- compatability-report.tap || touch compatability-report.tap
        cp compatability-report.tap "${DIR}/"
    )
    make -s generate-report DIR="${DIR}" > "${TMPDR}/Compatibility-matrix.md"
    cp "${DIR}/.tap" "${TMPDR}/compatability-report.tap"
    cp ../README.md "${TMPDR}/Home.md"

    github_wiki_commit "${TMPDR}"
    exit 0
) || (
    echo "Not on \`master' branch - not publishing, only printing."
    make -s generate-report DIR="${DIR}"
)
