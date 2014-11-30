
$wxHaskellPath = "c:\wxHaskell"

$GHC_VNO="7.8.3"
$WXC_VNO="0.91.0.0"
$wxWidgetsVersion="3.0.2"

$USERHOMEDIR="c:\Users\$env:USERNAME"
$APPDATA="$USERHOMEDIR\AppData\Roaming"
$cabalBin="$APPDATA\cabal\bin"
$haskellPlatform = "C:\Program Files (x86)\Haskell Platform\2014.2.0.0"

$wxWidgetsZip="wxWidgets-$wxWidgetsVersion.zip"

$downloadDir = "$PSScriptRoot\download"
$mingw = "C:\MinGW"
$tempDir = $env:Temp

$WXDIR="C:\wxWidgets-autob"


$wxWidgetsExistsOnStartup = Test-Path $WXDIR
function Pause
{
    param([string] $pauseKey,
            [ConsoleModifiers] $modifier,
            [string] $prompt,
            [bool] $hideKeysStrokes)
             
    Write-Host -NoNewLine "Press $prompt to continue . . . "
    do
    {
        $key = [Console]::ReadKey($hideKeysStrokes)
    } 
    while(($key.Key -ne $pauseKey) -or ($key.Modifiers -ne $modifer))   
     
    Write-Host
}

function PauseG ($prompt)
{
  Write-Host
  Write-Host $prompt
  $modifer = [ConsoleModifiers]::Control
  Pause "G" $modifer "Ctrl + G" $true
  
  Write-Host
}

function PauseYN
{             
	$modifer = [ConsoleModifiers]::Control
			 
    Write-Host -NoNewLine "Press (Ctrl + Y) or (Ctrl + N) to continue . . . "
    do
    {
        $key = [Console]::ReadKey($true)
    } 
    while(($key.Key -ne "Y" -and $key.Key -ne "N") -or ($key.Modifiers -ne $modifer))   
     
    Write-Host
	
    return $key.Key
}

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
& {
    if (!$currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator ))
    {
	    #Admin mode is required to download to C:\ possibly other things too.
        PauseG "You are not running in Admin mode! Script will now exit."
		Exit
    }
}

function GetRandomString ([int]$Length)
{
	$set    = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
	$result = ""
	for ($x = 0; $x -lt $Length; $x++) {
		$result += $set | Get-Random
	}
	return $result
}

#function ClearAllEnvironmentVariables
#{
#Get-ChildItem Env:
#}



if (!(Test-Path $haskellPlatform)){
Write-Host "You need to install the Haskell Platform ($haskellPlatform)!"
return
}
$7zip = "C:\Program Files\7-Zip"

if (!(Test-Path $7zip)){
Write-Host "You need to install 7-ZIP!"
return
}

Function GhcGitDownload ($file) {
    #download if download does not exist
    if (!(Test-Path "$downloadDir\$file")){
		Write-Host "Downloading from http://git.haskell.org/ghc-tarballs.git/: $file"
		Invoke-WebRequest "http://git.haskell.org/ghc-tarballs.git/blob/e7b7b152083f7c3e3559e557a239757d41ac02a6:/mingw/$file" -OutFile "$downloadDir\$file"
    }	
}

Function SfDownload ($project, $htmlpath, $outfile) {

    #download if download does not exist
    if (!(Test-Path $outfile)){
        $sourceR = "http://sourceforge.net/projects/$project/files/$htmlpath/download"
        $Rparam = $sourceR -replace ":", "%3A" -replace "/", "%2F" -replace " ", "%20" -replace [regex]::Escape("+"), "%2B"

        #setup parameters for Sourceforge download
		$timestamp=[Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
		$parameters="?r=$Rparam&use_mirror=autoselect&ts=$timestamp" 
		$source = "http://downloads.sourceforge.net/project/$project/$htmlpath$parameters"
	
		# download from sourceforge
		Write-Host "Downloading from SourceForge: /$project/$htmlpath"
		Invoke-WebRequest $source -OutFile $outfile
		
    }	
}

#If !exists Then create build directory
if (!(Test-Path $downloadDir)){
	New-Item $downloadDir -ItemType directory 
}

Function UnzipWxWidgets
{
    #unzip if folder does not exist
    if (!(Test-Path $WXDIR)){
      unzip "$downloadDir/$wxWidgetsZip" -d $WXDIR
	}
}

Function Un7 ($zipfile, $output)
{
 $curr = (Get-Location).Path
 $tarfile = $zipfile -replace ".lzma", "" -replace ".gz", ""
 
 Invoke-Expression "& '$7zip\7z' -y x $downloadDir\$zipfile -o$tempDir"
 cd $tempDir
 Invoke-Expression "& '$7zip\7z' -y x $tarfile -o$output"
 cd $curr
}

SfDownload "wxwindows" "$wxWidgetsVersion/$wxWidgetsZip" "$downloadDir\$wxWidgetsZip"
UnzipWxWidgets

#download and run installer if MinGW is not installed.
if (!(Test-Path $mingw)){
	$mingwVno="5.1.6"
	$mingwExe="MinGW-$mingwVno.exe"

	SfDownload "mingw" "OldFiles/MinGW%20$mingwVno/$mingwExe" "$downloadDir\$mingwExe"
  
	PauseG "MinGW installer will launch next. Remember to install the C++ compiler and MinGW-make options"  
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

#grab wx-config from SourceForge
SfDownload "wxhaskell" "wx-config-win/wx-config.exe" "$cabalBin\wx-config.exe"

PauseG "We will next install a GHC compatible version of GCC into MinGW. This will overwrite the version of GCC currently installed in MinGW."

#download GCC/MinGW packages
$libs = @("binutils-2.20.51-1-mingw32-bin.tar.lzma","gcc-c++-4.5.2-1-mingw32-bin.tar.lzma","gcc-core-4.5.2-1-mingw32-bin.tar.lzma","libgcc-4.5.2-1-mingw32-dll-1.tar.lzma","libgmp-5.0.1-1-mingw32-dll-10.tar.lzma","libmpc-0.8.1-1-mingw32-dll-2.tar.lzma","libmpfr-2.4.1-1-mingw32-dll-1.tar.lzma","libstdc++-4.5.2-1-mingw32-dll-6.tar.lzma","mingwrt-3.18-mingw32-dev.tar.gz","mingwrt-3.18-mingw32-dll.tar.gz","w32api-3.15-1-mingw32-dev.tar.lzma")

foreach ($lib in $libs) {
	GhcGitDownload $lib #download, if have not already done so
	Un7 $lib $mingw  #unzip
}

$wxHaskellHex = "c5dae78e37e492fd5f801ca118e80ba3e2f0ce99"
function wxHaskell {	
	$source = "https://github.com/wxHaskell/wxHaskell/archive/$wxHaskellHex.zip"
    $wxHaskellFile = "wxHaskell_$wxHaskellHex"
	#download wxHaskell from Github
	if (!(Test-Path "$downloadDir\$wxHaskellFile")){
		
			Write-Host "Downloading $source"
			Invoke-WebRequest $source -OutFile "$downloadDir\$wxHaskellFile"
	}

	if (!(Test-Path $wxHaskellPath)){
		  unzip "$downloadDir/$wxHaskellFile" -d $wxHaskellPath
	}

}
wxHaskell

########################     BUILD       ##############

$PATHWX="$WXDIR\lib\gcc_dll;$WXDIR;$APPDATA\cabal\bin;$APPDATA\cabal\i386-windows-ghc-$GHC_VNO\wxc-$WXC_VNO"
$PATHHP="$haskellPlatform\mingw\bin;$haskellPlatform\lib\extralibs\bin;$haskellPlatform\bin"
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
    Write-Host "Do you wish to clean wxWidgets prior to building?"
    $response1 = PauseYN

	if ($response1 -eq "Y") {
		CleanWxWidgets
	}
} else {
	CleanWxWidgets
}

PauseG "The contents of $wxWidgetsZip will now be built."
Invoke-Expression "& 'mingw32-make' -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release"

# ----QUICK-FIX---- for wxWidgets-3.0.2
copy $WXDIR\build\msw\gcc_mswudll\coredll_headerctrlg.o $WXDIR\build\msw\gcc_mswudll\coredll_headerctlg.o
Invoke-Expression "& 'mingw32-make' -j4 -f makefile.gcc SHELL=CMD.exe SHARED=1 UNICODE=1 BUILD=release"
# ----END QUICK-FIX---- remove this fix for other versions.  Or find a better fix for this version.

#change path to use Haskell Platform's GCC (4.5.2)
$env:Path = "$PATHHP;$PATHWX;$PATHMINGW;$PATHWIN"

$wxHexPath="$wxHaskellPath\wxHaskell-$wxHaskellHex"
cd "$wxHexPath\wxdirect"
Invoke-Expression "& 'cabal' configure"
Invoke-Expression "& 'cabal' install"
cd "$wxHexPath\wxcore"
Invoke-Expression "& 'cabal' configure"
Invoke-Expression "& 'cabal' install"
cd "$wxHexPath\wxc"
Invoke-Expression "& 'cabal' configure"
Invoke-Expression "& 'cabal' install"
cd "$wxHexPath\wx"
Invoke-Expression "& 'cabal' configure"
Invoke-Expression "& 'cabal' install"

## make wxHaskell samples
cd "$wxHexPath\samples\wx"
Invoke-Expression "& 'mingw32-make' -j4 SHELL=CMD.exe"
## END  -- make wxHaskell samples

########################## Export Environment ##################

#list out the environment variables needed to launch a wxHaskell program.
Write-Host "Do you wish to export these environment variables permanently? This will allow you to easily launch wxHaskell programs. Y or N"
$response2 = PauseYN




cd $PSScriptRoot