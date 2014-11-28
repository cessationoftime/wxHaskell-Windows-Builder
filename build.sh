#!/bin/sh

#the directory of this script file
ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir $ROOTDIR/build
mkdir $ROOTDIR/build/wxWidgets
cd $ROOTDIR/build/wxWidgets

wxWidgetsZip="wxWidgets-3.0.2.zip"

$ROOTDIR/wGet/bin/wget.exe https://sourceforge.net/projects/wxwindows/files/3.0.2/$wxWidgetsZip --no-check-certificate
unzip $wxWidgetsZip
