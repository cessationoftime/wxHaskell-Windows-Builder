
$USERHOMEDIR="c:\Users\$env:USERNAME"
$APPDATA="$USERHOMEDIR\AppData\Roaming"
$cabalBin="$APPDATA\cabal\bin"

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

$haskellPlatform = "C:\Program Files (x86)\Haskell Platform\2014.2.0.0"

if (!(Test-Path $haskellPlatform)){
echo "You need to install the Haskell Platform ($haskellPlatform)!"
return
}
$7zip = "C:\Program Files\7-Zip"

if (!(Test-Path $7zip)){
echo "You need to install 7-ZIP!"
return
}

$wxWidgetsVersion="3.0.2"
$wxWidgetsZip="wxWidgets-$wxWidgetsVersion.zip"

Function GhcGitDownload ($file) {
    #download if download does not exist
    if (!(Test-Path "$buildDir\$file")){
		echo "Downloading from http://git.haskell.org/ghc-tarballs.git/: $outfile"
		Invoke-WebRequest "http://git.haskell.org/ghc-tarballs.git/tree/e7b7b152083f7c3e3559e557a239757d41ac02a6:/mingw/$file" -OutFile "$buildDir\$file"
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
		echo "Downloading from SourceForge: /$project/$htmlpath"
		Invoke-WebRequest $source -OutFile $outfile
		
    }	
}

$buildDir = "$PSScriptRoot\build"
$mingw = "C:\MinGW"
$tempDir = $env:Temp
#If !exists Then create build directory
if (!(Test-Path $buildDir)){
	New-Item $buildDir -ItemType directory 
}

Function UnzipWxWidgets
{
    #unzip if folder does not exist
    $unzipDest = "C:\wxWidgets-autob"
    if (!(Test-Path $unzipDest)){
      unzip "$buildDir/$wxWidgetsZip" -d $unzipDest
	}
}

Function Un7 ($zipfile, $output)
{
 $curr = (Get-Location).Path
 $tarfile = $zipfile -replace ".lzma", "" -replace ".gz", ""
 
 Invoke-Expression "& '$7zip\7z' -y x $buildDir\$zipfile -o$tempDir"
 cd $tempDir
 Invoke-Expression "& '$7zip\7z' -y x $tarfile -o$output"
 cd $curr
}

SfDownload "wxwindows" "$wxWidgetsVersion/$wxWidgetsZip" "$buildDir\$wxWidgetsZip"
UnzipWxWidgets

#download and run installer if MinGW is not installed.
if (!(Test-Path $mingw)){
	$mingwVno="5.1.6"
	$mingwExe="MinGW-$mingwVno.exe"

	SfDownload "mingw" "OldFiles/MinGW%20$mingwVno/$mingwExe" "$buildDir\$mingwExe"
  
	PauseG "MinGW installer will launch next. Remember to install the C++ compiler and MinGW-make options"  
	Invoke-Expression "& '$buildDir\$mingwExe'"
	PauseG "Continue when MingW installation finished."
}
if (!(Test-Path "C:\msys\1.0")){  
    $msysVno="1.0.11"
    $msysExe="MSYS-$msysVno.exe"
  
    SfDownload "mingw" "MSYS/Base/msys-core/msys-$msysVno/$msysExe" "$buildDir\$msysExe"
	
	PauseG "Msys installer will launch next. When finished check that /etc/fstab is correct,  so that /mingw mounts correctly. It should not be empty!"
	Invoke-Expression "& '$buildDir\$msysExe'"
	PauseG "Continue when Msys installation finished."
}

PauseG "This is the version of GCC that comes with the Haskell Platform, we need to install a compatible version into MinGW"

#gcc version 3.4.5
#/c/MinGW/bin/gcc --version
#gcc version 4.6.3
Invoke-Expression "& '$haskellPlatform\mingw\bin\gcc' --version"

Write-Host "MinGW currently has: "
Invoke-Expression "& '$mingw\bin\gcc' --version"
PauseG "If Haskell has GCC version 4.6.3 then we need 4.6.x. We will install 4.6.2 into MinGW."

$libs = @("binutils-2.20.51-1-mingw32-bin.tar.lzma","gcc-c++-4.5.2-1-mingw32-bin.tar.lzma","gcc-core-4.5.2-1-mingw32-bin.tar.lzma","libgcc-4.5.2-1-mingw32-dll-1.tar.lzma","libgmp-5.0.1-1-mingw32-dll-10.tar.lzma","libmpc-0.8.1-1-mingw32-dll-2.tar.lzma","libmpfr-2.4.1-1-mingw32-dll-1.tar.lzma","libstdc++-4.5.2-1-mingw32-dll-6.tar.lzma","mingwrt-3.18-mingw32-dev.tar.gz","mingwrt-3.18-mingw32-dll.tar.gz","w32api-3.15-1-mingw32-dev.tar.lzma")

foreach ($lib in $libs) {
	GhcGitDownload $lib #download, if have not already done so
	Un7 $lib $mingw  #unzip
}

<#
Write-Host "How to install GCC components in MINGW: http://www.mingw.org/node/24/revisions/897/view"

#download gcc componenets
#http://sourceforge.net/projects/mingw/files/MinGW/Base/gcc/Version4/gcc-4.6.2-1/

#....MAYBE  http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/rubenvb/gcc-4.6-release/

#http://www.mingw.org/node/24/revisions/897/view


$gccVersion = "4.6.2-1"
$gccDownloadPath = "MinGW/Base/gcc/Version4/gcc-$gccVersion"
$gccCore = [System.Tuple]::Create($gccDownloadPath,"gcc-core-$gccVersion-mingw32-bin.tar.lzma")
$libGcc = [System.Tuple]::Create($gccDownloadPath,"libgcc-$gccVersion-mingw32-dll-1.tar.lzma") 
$gccCpp = [System.Tuple]::Create($gccDownloadPath,"gcc-c++-$gccVersion-mingw32-bin.tar.lzma")
$libstdcpp = [System.Tuple]::Create($gccDownloadPath,"libstdc++-$gccVersion-mingw32-dll-6.tar.lzma")

$gmpVersion = "5.0.1-1"
$gmpDownloadPath = "MinGW/Base/gmp/gmp-$gmpVersion"
$gmp = [System.Tuple]::Create($gmpDownloadPath,"gmp-$gmpVersion-mingw32-dev.tar.lzma")
$libgmp = [System.Tuple]::Create($gmpDownloadPath,"libgmp-$gmpVersion-mingw32-dll-10.tar.lzma")

$mpcVersion = "0.8.1-1"
$mpcDownloadPath = "MinGW/Base/mpc/mpc-$mpcVersion"
$mpc = [System.Tuple]::Create($mpcDownloadPath,"mpc-$mpcVersion-mingw32-dev.tar.lzma")
$libmpc = [System.Tuple]::Create($mpcDownloadPath,"libmpc-$mpcVersion-mingw32-dll-2.tar.lzma")

$mpfrVersion = "2.4.1-1"
$mpfrDownloadPath = "MinGW/Base/mpfr/mpfr-$mpfrVersion"
$mpfr = [System.Tuple]::Create($mpfrDownloadPath,"mpfr-$mpfrVersion-mingw32-dev.tar.lzma")
$libmpfr = [System.Tuple]::Create($mpfrDownloadPath,"libmpfr-$mpfrVersion-mingw32-dll-1.tar.lzma")

$pthreadsVersion = "pre-20110507-2"
$pthreadsDownloadPath = "MinGW/Base/pthreads-w32/pthreads-w32-2.9.0-$pthreadsVersion"
$pthreads = [System.Tuple]::Create($pthreadsDownloadPath,"pthreads-w32-2.9.0-mingw32-$pthreadsVersion-dev.tar.lzma")
$libpthreads = [System.Tuple]::Create($pthreadsDownloadPath,"libpthreadgc-2.9.0-mingw32-$pthreadsVersion-dll-2.tar.lzma")

$libiconvVersion = "1.14-2"
$libiconvDownloadPath = "MinGW/Base/libiconv/libiconv-$libiconvVersion"
$libiconvDev = [System.Tuple]::Create($libiconvDownloadPath,"libiconv-$libiconvVersion-mingw32-dev.tar.lzma")
$libiconvDll = [System.Tuple]::Create($libiconvDownloadPath,"libiconv-$libiconvVersion-mingw32-dll-2.tar.lzma")

$gettext = [System.Tuple]::Create("MinGW/Base/gettext/gettext-0.18.1.1-2","libintl-0.18.1.1-2-mingw32-dll-8.tar.lzma")

$libgomp = [System.Tuple]::Create($gccDownloadPath,"libgomp-$gccVersion-mingw32-dll-1.tar.lzma")
$libssp = [System.Tuple]::Create($gccDownloadPath,"libssp-$gccVersion-mingw32-dll-0.tar.lzma")
$libquadmath = [System.Tuple]::Create($gccDownloadPath,"libquadmath-$gccVersion-mingw32-dll-0.tar.lzma")

$win32 = [System.Tuple]::Create("MinGW/Base/w32api/w32api-3.17","w32api-3.17-2-mingw32-dev.tar.lzma")

$libs = @($gccCore, $libGcc, $gccCpp, $libstdcpp, $gmp, $libgmp, $mpc,$libmpc,$mpfr,$libmpfr,$pthreads,$libpthreads,$libiconvDev,$libiconvDll,$gettext,$libgomp, $libssp, $libquadmath, $win32)
foreach ($lib in $libs) {
	SfDownload "mingw" "$($lib.Item1)/$($lib.Item2)" "$buildDir\$($lib.Item2)"
}	

#SfDownload "mingw" "$gccDownloadPath/$gccCore" "$buildDir\$gccCore.Item2"
#SfDownload "mingw" "$gccDownloadPath/$libGcc" "$buildDir\$libGcc"
#SfDownload "mingw" "$gccDownloadPath/$gccCpp" "$buildDir\$gccCpp"
#SfDownload "mingw" "$gccDownloadPath/$libstdcpp" "$buildDir\$libstdcpp"

#SfDownload "mingw" "$gmpDownloadPath/$gmp" "$buildDir\$gmp"
#SfDownload "mingw" "$gmpDownloadPath/$libgmp" "$buildDir\$libgmp"

Write-Host "We will now upgrade (overwrite) MinGW's gcc packages to 4.6.x ($gccVersion) so to be compatible with ghc's gcc (4.6.3)"

Write-Host "gcc-core, libgcc"
Write-Host "gcc-c++, libstdc++"
Write-Host "gmp-dev, libgmp-dll"
PauseG     ""

#dump tar.lzma contents into mingw
foreach ($lib in $libs) {
	Un7 "$($lib.Item2)" "$mingw"
}
#>
PauseG "The following GCC is now installed in MinGW: "
Invoke-Expression "& '$mingw\bin\gcc' --version"

$wxConfigExe="wx-config.exe"
SfDownload "wxhaskell" "wx-config-win/$wxConfigExe" "$cabalBin\$wxConfigExe"