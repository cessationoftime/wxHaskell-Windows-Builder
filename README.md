wxHaskell-Windows-Builder
=========================

Script to download all dependencies of wxHaskell and build it on Windows.

# Support for 32-bit GHC ONLY
* Per the [wxHaskell building docs](https://www.haskell.org/haskellwiki/WxHaskell/Building#Supported_Configurations). Only building with the  32-bit MinGW project is supported. 
 

### About GHC and MinGW/GCC ###


 * There is a [ticket](https://ghc.haskell.org/trac/ghc/ticket/9218) to upgrade the version of MinGW that ships with GHC, that was initiated with [this thread](https://www.haskell.org/pipermail/ghc-devs/2014-June/005174.html)
 * Currently GHC uses MinGW for 32-bit and MinGW-w64 for the 64-bit version. This ticket intends to use the MinGW-w64 project for both the 32-bit and 64-bit versions. 
 * This will affect what MinGW/GCC version we need to use for wxWidgets/wxHaskell.
 * GHC 7.8.3  (Haskell Platform 2014.2.0.0)
	 * 64-bit includes GCC version [4.6.3](http://git.haskell.org/ghc-tarballs.git/tree/18e0c37f8023abf469af991e2fc2d3b024319c27:/mingw64) (from [sourceforge](http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/rubenvb/gcc-4.6-release/))
	 * 32-bit includes GCC version [4.5.2](http://git.haskell.org/ghc-tarballs.git/tree/e7b7b152083f7c3e3559e557a239757d41ac02a6:/mingw)

### Prerequisites for the windows builder tool: ###

* Haskell Platform 2014.2.0.0 for Windows, 32bit 
* 7-zip

	**For the Powershell download script**


* Windows7 SP1, (Windows 8 is untested)
* .NET 4.5 - http://www.microsoft.com/download/details.aspx?id=30653
* Windows Management Framework 4.0 -  http://www.microsoft.com/en-us/download/details.aspx?id=40855
* Have previously run "Set-ExecutionPolicy Unrestricted" in an Admin-enabled powershell. (You can run "Set-ExecutionPolicy Restricted" when finished).

### Running ###

* Run build.ps1 from powershell terminal (admin mode)

### Troubleshooting ###

wxWidgets-3.0.2 spits out this error when compiling in release mode.

```
g++: gcc_mswudll\coredll_headerctlg.o: No such file or directory
```

 I copied and renamed a file called  "coredll_headerctrlg.o" to "coredll_headerctlg.o" and this seems to be an adequate workaround. At the moment the script does this automatically.


