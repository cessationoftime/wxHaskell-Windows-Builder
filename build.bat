@echo off

REM unset all variables localy except for USERNAME

REM we are removing one too many env variables
REM FOR	/F "delims==" %%i IN ('set') DO IF NOT %%i==USERNAME SET "%%i="



set ROOTDIR=%~dp0
set BUILDDIR=%ROOTDIR%\build
set WXDIR=C:\wxWidgets-autob
set GHC_VNO=7.8.3
set WXC_VNO=0.91.0.0
set USERHOMEDIR=c:\Users\%USERNAME%
set APPDATA=%USERHOMEDIR%\AppData\Roaming
set HaskellPlatform=c:\Program Files (x86)\Haskell Platform\2014.2.0.0

set PATHWX=%WXDIR%\lib\gcc_dll;%WXDIR%;%APPDATA%\cabal\bin;%APPDATA%\cabal\i386-windows-ghc-%GHC_VNO%\wxc-%WXC_VNO%
set PATHHP=%HaskellPlatform%\mingw\bin;%HaskellPlatform%\lib\extralibs\bin;%HaskellPlatform%\bin
set PATHWIN=%USERHOMEDIR%\bin;c:\Windows\system32;c:\Windows;c:\Windows\System32\Wbem
set PATHMINGW=c:\MinGW\bin

REM use MinGW's GCC (should be updated to 4.5.2)
set PATH=%PATHMINGW%;%PATHWX%;%PATHWIN%

REM gcc --version
cd %WXDIR%/build/msw

REM mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release clean
REM mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release

REM mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release clean
mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release

REM cd %WXDIR%/samples/minimal

REM mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release clean
REM mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release

REM use Haskell Platform's GCC (4.5.2)
REM set PATH=%PATHHP%;%PATHWX%;%PATHMINGW%;%PATHWIN%

REM gcc --version
REM wx-config

cd %ROOTDIR%
