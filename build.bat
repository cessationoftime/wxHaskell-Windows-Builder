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

REM use MinGW's GHC (should be updated to 4.6.2)
set PATH=%PATHMINGW%;%PATHWX%;%PATHWIN%

gcc --version
cd %WXDIR%/build/msw

REM mingw32-make -f makefile.gcc SHELL=CMD.exe MONOLITHIC=1 SHARED=1 UNICODE=1 BUILD=release clean
REM mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe MONOLITHIC=1 SHARED=1 UNICODE=1 BUILD=release

mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe MONOLITHIC=1 SHARED=1 UNICODE=1 BUILD=debug clean
mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe MONOLITHIC=1 SHARED=1 UNICODE=1 BUILD=debug

cd %WXDIR%/samples/minimal

mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe MONOLITHIC=1 SHARED=1 UNICODE=1 BUILD=debug clean
mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe MONOLITHIC=1 SHARED=1 UNICODE=1 BUILD=debug

REM use Haskell Platform's GHC (4.6.3)
set PATH=%PATHHP%;%PATHWX%;%PATHMINGW%;%PATHWIN%

gcc --version
wx-config

cd %ROOTDIR%
