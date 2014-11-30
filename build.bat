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


REM ----BUILD wxWidgets----

REM change path to use MinGW's GCC (should be updated to 4.5.2)
set PATH=%PATHMINGW%;%PATHWX%;%PATHWIN%

cd %WXDIR%/build/msw

mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release clean
mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release

REM ----QUICK-FIX---- for wxWidgets-3.0.2
copy %WXDIR%\build\msw\gcc_mswudll\coredll_headerctrlg.o %WXDIR%\build\msw\gcc_mswudll\coredll_headerctlg.o
mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release
REM ----END QUICK-FIX---- remove this fix for other versions.  Or find a better fix for this version.

REM ----BUILD SAMPLES----
REM cd %WXDIR%/samples

REM mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release clean
REM mingw32-make -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release
REM ----END BUILD SAMPLES----

REM ---- END BUILD wxWidgets----

REM change path to use Haskell Platform's GCC (4.5.2)
set PATH=%PATHHP%;%PATHWX%;%PATHMINGW%;%PATHWIN%
REM mingw32-make -j4 SHELL=CMD.exe
REM gcc --version
REM wx-config

cd %ROOTDIR%
