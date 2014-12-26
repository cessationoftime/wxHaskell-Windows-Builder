
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
& {
    if (!$currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator ))
    {
	    #Admin mode is required to download to C:\ possibly other things too.
        PauseG "You are not running in Admin mode! Script will now exit."
		Exit
    }
}

#Remove-Module -Name buildmodule
Import-Module -Force .\buildmodule

SetEnvironment

$wxWidgetsVersion=$env:WXWIDGETS_VERSION

$wxHaskellPath = "c:\wxHaskell"


$USERHOMEDIR="c:\Users\$env:USERNAME"
$APPDATA="$USERHOMEDIR\AppData\Roaming"
$cabalBin="$APPDATA\cabal\bin"
$haskellPlatform = "C:\Program Files (x86)\Haskell Platform\2014.2.0.0"

$wxWidgetsZip="wxWidgets-$wxWidgetsVersion.zip"

$downloadDir = "$PSScriptRoot\download"

$env:DownloadDir = $downloadDir

$mingw = "C:\MinGW"
$tempDir = $env:Temp

$WXDIR = $env:WXWIN


$wxWidgetsExistsOnStartup = Test-Path $WXDIR




if (!(Test-Path $haskellPlatform)){
Write-Host "You need to install the Haskell Platform ($haskellPlatform)! Only the 32-bit version is supported."
return
}

if (!(Test-Path $env:zip7)){
Write-Host "You need to install 7-ZIP!"
return
}

#If !exists Then create build directory
CreateDirectoryIfNotExist $downloadDir



SfDownload "wxwindows" "$wxWidgetsVersion/$wxWidgetsZip" "$downloadDir\$wxWidgetsZip"
UnzipIfNotExist "$downloadDir\$wxWidgetsZip" $WXDIR

#download and run installer if MinGW is not installed.
if (!(Test-Path $mingw)){
	$mingwVno="5.1.6"
	$mingwExe="MinGW-$mingwVno.exe"

	SfDownload "mingw" "OldFiles/MinGW%20$mingwVno/$mingwExe" "$downloadDir\$mingwExe"
  
	PauseG "MinGW installer will launch next. Remember to install the C++ compiler and MinGW-make options. And install to $mingw"  
	Invoke-Expression "& '$downloadDir\$mingwExe'"
	PauseG "Continue when MingW installation finished."
}
if (!(Test-Path "C:\msys\1.0")){  
    $msysVno="1.0.11"
    $msysExe="MSYS-$msysVno.exe"
  
    SfDownload "mingw" "MSYS/Base/msys-core/msys-$msysVno/$msysExe" "$downloadDir\$msysExe"
	
	PauseG "Msys installer will launch next. When finished check that /etc/fstab is correct,  so that /mingw mounts correctly. It should not be empty!"
	Invoke-Expression "& '$downloadDir\$msysExe'"
	PauseG "Continue when Msys installation finished."
}

#create cabalBin directory if it doesn't exist yet. (wx-config needs to go there)
if (!(Test-Path $cabalBin)){
	New-Item $cabalBin -ItemType directory 
}
#grab wx-config from SourceForge
SfDownload "wxhaskell" "wx-config-win/wx-config.exe" "$cabalBin\wx-config.exe"

PauseG "We will next install a GHC compatible version of GCC into MinGW. This will overwrite the version of GCC currently installed in MinGW."

#download GCC/MinGW packages
$libs = @("binutils-2.20.51-1-mingw32-bin.tar.lzma","gcc-c++-4.5.2-1-mingw32-bin.tar.lzma","gcc-core-4.5.2-1-mingw32-bin.tar.lzma","libgcc-4.5.2-1-mingw32-dll-1.tar.lzma","libgmp-5.0.1-1-mingw32-dll-10.tar.lzma","libmpc-0.8.1-1-mingw32-dll-2.tar.lzma","libmpfr-2.4.1-1-mingw32-dll-1.tar.lzma","libstdc++-4.5.2-1-mingw32-dll-6.tar.lzma","mingwrt-3.18-mingw32-dev.tar.gz","mingwrt-3.18-mingw32-dll.tar.gz","w32api-3.15-1-mingw32-dev.tar.lzma")

foreach ($lib in $libs) {
	GhcGitDownload $lib #download, if have not already done so
	Un7 $lib $mingw  #unzip
}


wxHaskellDownload $wxHaskellPath

########################     BUILD       ##############

$env:WXC_PATH = "$APPDATA\cabal\i386-windows-ghc-$env:GHC_VERSION\wxc-$env:WXC_VERSION"
$env:HASKELL_MINGW_PATH = "$haskellPlatform\mingw\bin"
$env:CABAL_PATH = "$APPDATA\cabal\bin"
$env:WX_PATH = "$WXDIR\lib\gcc_dll;$WXDIR"

$PATHWX="$env:WX_PATH;$env:CABAL_PATH;$env:WXC_PATH"
$PATHHP="$env:HASKELL_MINGW_PATH;$haskellPlatform\lib\extralibs\bin;$haskellPlatform\bin"
$PATHWIN="$USERHOMEDIR\bin;c:\Windows\system32;c:\Windows;c:\Windows\System32\Wbem"
$PATHMINGW="c:\MinGW\bin"

# ----BUILD wxWidgets----



#change path to use MinGW's GCC (should be updated to 4.5.2)
$env:Path = "$PATHMINGW;$PATHWX;$PATHWIN"

cd $WXDIR/build/msw



function CleanWxWidgets {
		Invoke-Expression "& 'mingw32-make' -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release clean"
}

if ($wxWidgetsExistsOnStartup) {
    Write-Host "Do you wish to clean wxWidgets prior to building? (make sure to say YES if you have yet to build at all!)"
    $response1 = PauseYN

	if ($response1 -eq "Y") {
		CleanWxWidgets
	}
} else {
	CleanWxWidgets
}

#PauseG "The contents of $wxWidgetsZip will now be built."
Invoke-Expression "& 'mingw32-make' -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release"

# ----QUICK-FIX---- for wxWidgets-3.0.2
copy $WXDIR\build\msw\gcc_mswudll\coredll_headerctrlg.o $WXDIR\build\msw\gcc_mswudll\coredll_headerctlg.o
Invoke-Expression "& 'mingw32-make' -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release"
# ----END QUICK-FIX---- remove this fix for other versions.  Or find a better fix for this version.

Write-Host
Write-Host "Build wxWidgets samples?"
$responseWidgetsSamples = PauseYN

if ($responseWidgetsSamples -eq "Y") {
	## make wxWidgets samples
	cd "$WXDIR\samples"
	Invoke-Expression "& 'mingw32-make' -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release"
	## END  -- make wxWidgets samples
}
Write-Host
#change path to use Haskell Platform's GCC (4.5.2)
$env:Path = "$PATHHP;$PATHWX;$PATHMINGW;$PATHWIN"
$wxHaskellHex = getWxHaskellHex

Invoke-Expression "& 'cabal' update"
$wxHexPath="$wxHaskellPath\wxHaskell-$wxHaskellHex"
cd "$wxHexPath\wxdirect"
Invoke-Expression "& 'cabal' install --only-dependencies"
Invoke-Expression "& 'cabal' configure"
Invoke-Expression "& 'cabal' install"
Write-Host
Write-Host
Write-Host "WXC takes a little while to build, and doesn't print much output to powershell. Be patient."
Write-Host
Write-Host
cd "$wxHexPath\wxc"
Invoke-Expression "& 'cabal' install --only-dependencies"
Invoke-Expression "& 'cabal' configure"
Invoke-Expression "& 'cabal' install"
cd "$wxHexPath\wxcore"
Invoke-Expression "& 'cabal' install --only-dependencies"
Invoke-Expression "& 'cabal' configure"
Invoke-Expression "& 'cabal' install"
cd "$wxHexPath\wx"
Invoke-Expression "& 'cabal' install --only-dependencies"
Invoke-Expression "& 'cabal' configure"
Invoke-Expression "& 'cabal' install"

Write-Host
Write-Host "Build wxHaskell samples?"
$responseWxHaskellSamples = PauseYN

if ($responseWxHaskellSamples -eq "Y") {
## make wxHaskell samples
cd "$wxHexPath\samples\wx"
Invoke-Expression "& 'mingw32-make' -j4 SHELL=CMD.exe"
## END  -- make wxHaskell samples
}

Write-Host
Write-Host
Write-Host
Write-Host
########################## Export Environment ##################

Write-Host "The following environment settings need to be added to the Windows User (not Machine/System) environment manually for wxHaskell programs to run: "
Write-Host "GHC_VERSION = $env:GHC_VERSION"
Write-Host "WXC_VERSION = $env:WXC_VERSION"
Write-Host "WXCFG = $env:WXCFG"
Write-Host "WXWIN = $env:WXWIN"
Write-Host "WXC_PATH = $env:WXC_PATH"
Write-Host "HASKELL_MINGW_PATH = $env:HASKELL_MINGW_PATH"
Write-Host "WX_PATH = $env:WX_PATH"
$prependThese = "%WXC_PATH%;%HASKELL_MINGW_PATH%;%WX_PATH%"
Write-Host
Write-Host
Write-Host "$prependThese should be prepended to the USER PATH variable"
Write-Host
#TODO: make it write the environment vars permanently.
Write-Host "Do you wish to export these environment variables permanently? This will allow you to easily launch wxHaskell programs. Y or N"
$response2 = PauseYN

Write-Host


#set environment permanently
if ($response2 -eq "Y"){
	
	
    $userCurrentPath = [Environment]::GetEnvironmentVariable("PATH", "User" )

	if ($userCurrentPath -eq $null) {
		[Environment]::SetEnvironmentVariable("PATH","$prependThese" , "User" )
	} else {
		if (!($userCurrentPath.Contains($prependThese))) {
			[Environment]::SetEnvironmentVariable("PATH","$prependThese;$userCurrentPath" , "User" )
		}
	}
	
	
	[Environment]::SetEnvironmentVariable("WXC_PATH",$env:WXC_PATH, "User" )
	[Environment]::SetEnvironmentVariable("HASKELL_MINGW_PATH",$env:HASKELL_MINGW_PATH, "User" )
	[Environment]::SetEnvironmentVariable("WX_PATH",$env:WX_PATH, "User")
	[Environment]::SetEnvironmentVariable("GHC_VERSION", $env:GHC_VERSION, "User")
	[Environment]::SetEnvironmentVariable("WXC_VERSION", $env:WXC_VERSION, "User")
	[Environment]::SetEnvironmentVariable("WXCFG", $env:WXCFG, "User")
	[Environment]::SetEnvironmentVariable("WXWIN", $env:WXWIN, "User")
	
	Write-Host "NOTE: you will not be able to launch wxHaskell programs via windows explorer until you logout, reboot, or propagate the new PATH variable in some other way. You can however launch them via powershell commands immediately."	
}

if ($responseWxHaskellSamples -eq "Y") {
  cd "$wxHexPath\samples\wx"
  Write-Host "Launching wxHaskell sample, BouncingBalls"
  Invoke-Expression "& '.\BouncingBalls'"
} else {
  cd $PSScriptRoot
}
