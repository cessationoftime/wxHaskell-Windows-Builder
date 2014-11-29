wxHaskell-Windows-Builder
=========================

Script to download all dependencies of wxHaskell and build it on Windows.

# Support for 32-bit GHC ONLY
* Per the [wxHaskell building docs](https://www.haskell.org/haskellwiki/WxHaskell/Building#Supported_Configurations). Only building withthe  32-bit MinGW project is supported. 
 

### About GHC and MinGW/GCC ###


 * There is a [ticket](https://ghc.haskell.org/trac/ghc/ticket/9218) to upgrade the version of MinGW that ships with GHC
 * Currently GHC uses MinGW for 32-bit and MinGW-w64 for the 64-bit version. This ticket intends to use the MinGW-w64 project for both the 32-bit and 64-bit versions. 
 * This affects what MinGW/GCC version we need to use for wxWidgets/wxHaskell.
 * Haskell Platform 2014.2.0.0 
	 * 64-bit includes GCC version [rubenvb-4.6.3](http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/rubenvb/gcc-4.6-release/)
 * Note: MinGW tarballs used with the GHC project are [here](http://git.haskell.org/ghc-tarballs.git/tree)

### Prerequisites for the windows builder tool: ###

* Haskell Platform 2014.2.0.0 for Windows, 32bit 
* 7-zip

	**For the Powershell download script**


* Windows7 SP1, (Windows 8 is untested)
* .NET 4.5 - http://www.microsoft.com/download/details.aspx?id=30653
* Windows Management Framework 4.0 -  http://www.microsoft.com/en-us/download/details.aspx?id=40855
* Have previously run "Set-ExecutionPolicy Unrestricted" in an Admin-enabled powershell. (You can run "Set-ExecutionPolicy Restricted" when finished).

### Running ###

* Run download.ps1 from powershell  terminal
* Run build.bat from cmd
