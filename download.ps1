
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

$wxWidgetsVersion="3.0.2"
$wxWidgetsZip="wxWidgets-$wxWidgetsVersion.zip"

Function SfDownload ($project, $htmlpath, $outfile) {

    #download if download does not exist
    if (!(Test-Path $outfile)){
        $sourceR = "http://sourceforge.net/projects/$project/files/$htmlpath/download"
        $Rparam = $sourceR -replace ":", "%3A" -replace "/", "%2F" -replace " ", "%20"

        #setup parameters for Sourceforge download
		$timestamp=[Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
		$parameters="?r=$Rparam&use_mirror=autoselect&ts=$timestamp" 
		$source = "http://downloads.sourceforge.net/project/$project/$htmlpath$parameters"
	
		# download from sourceforge
		echo "Downloading from SourceForge: /$project/$htmlpath"
		Invoke-WebRequest $source -OutFile $outfile
		
    }	
}

$buildDir = "$PSScriptRoot/build"

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


SfDownload "wxwindows" "$wxWidgetsVersion/$wxWidgetsZip" "$buildDir\$wxWidgetsZip"
UnzipWxWidgets

#download and run installer if MinGW is not installed.
if (!(Test-Path "C:\MinGW")){
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
Invoke-Expression "& 'c:\MinGW\bin\gcc' --version"