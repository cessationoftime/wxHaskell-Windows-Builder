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
$mingwVno="5.1.6"
$mingwExe="MinGW-$mingwVno.exe"

SfDownload "wxwindows" "$wxWidgetsVersion/$wxWidgetsZip" "$buildDir\$wxWidgetsZip"
UnzipWxWidgets

#download and run installer if MinGW is not installed.
if (!(Test-Path "C:\MinGW")){
  SfDownload "mingw" "OldFiles/MinGW%20$mingwVno/$mingwExe" "$buildDir\$mingwExe"
  Invoke-Expression "& '$buildDir\$mingwExe'"
}

