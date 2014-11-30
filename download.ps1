
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

#grab wx-config from SourceForge
SfDownload "wxhaskell" "wx-config-win/wx-config.exe" "$cabalBin\wx-config.exe"

PauseG "We will next install a GHC compatible version of GCC into MinGW. This will overwrite the version of GCC currently installed in MinGW."

$libs = @("binutils-2.20.51-1-mingw32-bin.tar.lzma","gcc-c++-4.5.2-1-mingw32-bin.tar.lzma","gcc-core-4.5.2-1-mingw32-bin.tar.lzma","libgcc-4.5.2-1-mingw32-dll-1.tar.lzma","libgmp-5.0.1-1-mingw32-dll-10.tar.lzma","libmpc-0.8.1-1-mingw32-dll-2.tar.lzma","libmpfr-2.4.1-1-mingw32-dll-1.tar.lzma","libstdc++-4.5.2-1-mingw32-dll-6.tar.lzma","mingwrt-3.18-mingw32-dev.tar.gz","mingwrt-3.18-mingw32-dll.tar.gz","w32api-3.15-1-mingw32-dev.tar.lzma")

foreach ($lib in $libs) {
	GhcGitDownload $lib #download, if have not already done so
	Un7 $lib $mingw  #unzip
}