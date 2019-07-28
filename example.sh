#!/bin/sh

## Usage: ${PROGNAME} [-h|--help] | { [-n|--nan <NUMBER>]
##        ${PROGPADD}                 [-l|--list-dir <DIRECTORY>]
##        ${PROGPADD}                 <ARGUMENT 1> [<ARG 2... }
##
##  This is a tool for a  specific purpose. We suggest to describe the
##  overall idea behind the tool here in the first section.
##
##  We can also add additional notes in a later section, before moving
##  on to describing the available options.
##
##   -h, --help
##          Display this helpful usage information
##
##   -n, --nan <NUMBER>
##          Say NaN this many times. (Default value: '${NAN_COUNT}'.)
##
##   -l, --list-dir <DIRECTORY>
##          List the contents of given directory.
##          (Default value: '${DIR}'.)
##
##   <ARGUMENT #>
##          Print out each argument at the end of the script. At least
##          one argument is required.
##
## Blame (most) bugs on: Martin Kjellstrand <martin.kjellstrand@madworx.se>.
# https://github.com/madworx/docshell

# Our default values:
DIR="."
NAN_COUNT="10"

#
# Print the usage  of this tool. Extracts this  documentation from the
# source code of the script itself.
#
program_path="$0"
usage() {
    export PROGNAME="${program_path##*/}"
    PROGPADD="$(echo "${PROGNAME}" | sed 's#.# #g')"
    export PROGPADD
    (echo "cat <<EOT"
     sed -n 's/^## \{0,1\}//p' < "${program_path}"
     echo "EOT") > /tmp/.help.$$ ; . /tmp/.help.$$ ; rm /tmp/.help.$$
}

# Parse command line options:
while [ "$#" -gt 0 ] ; do
    case "$1" in
        -h|--help) usage ; exit 0 ;;
        -n|--nan) NAN_COUNT="$2" ; shift 2 ;;
        -l|--list-dir) DIR="$2" ; shift 2 ;;
        -*) echo "Error: Unknown option '$1'." 1>&2 ; usage ; exit 64 ;; # EX_USAGE
        *) REST="${REST} $1" ; shift ;
    esac
done

# ----- YOUR APPLICATION CODE GOES HERE -----

[ -z "${REST}" ] && usage && exit 64 # EX_USAGE

# Our application code:
for N in $(seq 1 ${NAN_COUNT}) ; do
    echo -n "NaN "
done
echo "...Batman!"

echo ""
echo "Contents of directory: \`${DIR}':"
ls -l "${DIR}"

echo ""
echo "The rest of the arguments on the command line: ${REST}"
