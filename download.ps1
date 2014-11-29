
function ClearAllEnvironmentVariables
{
Get-ChildItem Env:
}

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

$haskellPlatform = "C:\Program Files\Haskell Platform\2014.2.0.0"

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
    $unzipDest = "$buildDir/wxWidgets"
    if (!(Test-Path $unzipDest)){
      unzip "$buildDir/$wxWidgetsZip" -d $unzipDest
	}
}

Function Un7 ($zipfile, $output)
{
 $curr = (Get-Location).Path
 $tarfile = $zipfile -replace ".lzma", ""
 
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

PauseG "We need to install the following version of GCC into MingW"

#gcc version 3.4.5
#/c/MinGW/bin/gcc --version
#gcc version 4.6.3
Invoke-Expression "& 'C:\Program Files\Haskell Platform\2014.2.0.0\mingw\bin\gcc' --version"


PauseG "Instead of"
Invoke-Expression "& '$mingw\bin\gcc' --version"

Write-Host "How to install GCC components in MINGW: http://www.mingw.org/node/24/revisions/897/view"

#download gcc componenets
#http://sourceforge.net/projects/mingw/files/MinGW/Base/gcc/Version4/gcc-4.6.2-1/

#....MAYBE  http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/rubenvb/gcc-4.6-release/

$gccVersion = "4.6.2-1"

$gccCore = "gcc-core-$gccVersion-mingw32-bin.tar.lzma"
$libGcc = "libgcc-$gccVersion-mingw32-dll-1.tar.lzma"
$gccCpp = "gcc-c++-$gccVersion-mingw32-bin.tar.lzma"
$libstdcpp = "libstdc++-$gccVersion-mingw32-dll-6.tar.lzma"

SfDownload "mingw" "MinGW/Base/gcc/Version4/gcc-$gccVersion/$gccCore" "$buildDir\$gccCore"
SfDownload "mingw" "MinGW/Base/gcc/Version4/gcc-$gccVersion/$libGcc" "$buildDir\$libGcc"
SfDownload "mingw" "MinGW/Base/gcc/Version4/gcc-$gccVersion/$gccCpp" "$buildDir\$gccCpp"
SfDownload "mingw" "MinGW/Base/gcc/Version4/gcc-$gccVersion/$libstdcpp" "$buildDir\$libstdcpp"

Write-Host "We will now upgrade (overwrite) MinGW's gcc packages to 4.6.x ($gccVersion) so to be compatible with ghc's gcc (4.6.3)"
Write-Host "gcc-core"
Write-Host "libgcc"
Write-Host "gcc-c++"
PauseG     "libstdc++"


#dump tar.lzma contents into mingw
Un7 "$gccCore" "$mingw"
Un7 "$libGcc" "$mingw"
Un7 "$gccCpp" "$mingw"
Un7 "$libstdcpp" "$mingw"