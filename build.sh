#!/bin/sh

######
# Run from MingW/Msys
######

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

/usr/bin/env -i USERNAME="$USERNAME" /bin/sh "$ROOTDIR\dobuild.sh"