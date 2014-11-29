wxHaskell-Windows-Builder
=========================

Script to download all dependencies of wxHaskell and build it on Windows.

### Prerequisites: ###

* Haskell Platform 2014.2.0.0 for Windows, 64bit 
* 7-zip

	**For the Powershell download script**


* Windows7 SP1, (Windows 8 is untested)
* .NET 4.5 - http://www.microsoft.com/download/details.aspx?id=30653
* Windows Management Framework 4.0 -  http://www.microsoft.com/en-us/download/details.aspx?id=40855
* Have previously run "Set-ExecutionPolicy Unrestricted" in an Admin-enabled powershell. (You can run "Set-ExecutionPolicy Restricted" when finished).

### Running ###

* Run download.ps1 from powershell  terminal
* Run build.sh from msys terminal
