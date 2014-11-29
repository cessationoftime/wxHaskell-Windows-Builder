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
PATHHP="$HaskellPlatform/mingw/bin:$HaskellPlatform/lib/extralibs/bin:$HaskellPlatform/bin"
PATHWIN="/c/Windows/system32:/c/Windows:/c/Windows/System32/Wbem"
PATHMINGW="/mingw/bin:/c/MinGW/bin:/usr/local/bin:/bin"
 

export GHC_VERSION=$GHC_VNO
export WXC_VERSION=$WXC_VNO
export WXWIN=$WXDIR
export WXCFG=gcc_dll\mswu

#http://mingw-users.1079350.n2.nabble.com/How-to-install-MinGW-with-an-older-compiler-version-gcc-g-4-6-X-td7578279.html

#use MinGW GCC
export PATH="$PATHMINGW:$PATHWX:$PATHHP:$HOME/bin:$PATHWIN"

gcc --version
cd /c/wxWidgets-autob/build/msw

mingw32-make -f makefile.gcc SHARED=1 UNICODE=1 BUILD=release clean
mingw32-make -j4 -f makefile.gcc SHARED=1 UNICODE=1 BUILD=release

#use Haskell Platform included GCC
export PATH="$PATHHP:$PATHWX:$PATHMINGW:$HOME/bin:$PATHWIN"

gcc --version