#!/bin/sh

######
# This script should not be launched directly. 
# Allow ./build.sh to launch this script, this removes unnecessary environment variables to reduce side effects.
######

#the directory of this script file
ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILDDIR=$ROOTDIR/build
WXDIR=$BUILDDIR/wxWidgets
GHC_VNO=7.8.3
WXC_VNO=0.91.0.0
HOME="/c/Users/$USERNAME"
APPDATA="$HOME/AppData/Roaming"
HaskellPlatform="/c/Program Files/Haskell Platform/2014.2.0.0"

PATHWX="$WXDIR/lib/gcc_dll:$WXDIR:$APPDATA/cabal/bin;$APPDATA/cabal/i386-windows-ghc-$GHC_VNO\wxc-$WXC_VNO"
PATHHP="$HaskellPlatform/mingw/bin:$HaskellPlatform/lib/extralibs/bin:$HaskellPlatform/bin:/usr/local/bin:/bin"
PATHWIN="/c/Windows/system32:/c/Windows:/c/Windows/System32/Wbem"
PATHMINGW="/mingw/bin:/c/MinGW/bin"
 

export PATH="$PATHWX:$PATHHP:$HOME/bin:$PATHWIN:PATHMINGW"
export GHC_VERSION=$GHC_VNO
export WXC_VERSION=$WXC_VNO
export WXWIN=$WXDIR
export WXCFG=gcc_dll\mswu

env
#http://mingw-users.1079350.n2.nabble.com/How-to-install-MinGW-with-an-older-compiler-version-gcc-g-4-6-X-td7578279.html