$wxWidgetsVersion="3.0.2"
$wxWidgetsZip="wxWidgets-$wxWidgetsVersion.zip"

Function DownloadWX ($zipfile)
{
    if (!(Test-Path $zipfile)){
	
		#setup parameters for Sourceforge download
		$timestamp=[Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
		$parameterR="http%3A%2F%2Fsourceforge.net%2Fprojects%2Fwxwindows%2Ffiles%2F$wxWidgetsVersion%2F$wxWidgetsZip%2Fdownload"
		$parameters="?r=$parameterR&use_mirror=autoselect&ts=$timestamp"
		$source = "http://downloads.sourceforge.net/project/wxwindows/$wxWidgetsVersion/$wxWidgetsZip$parameters"
	
	    # if File does not exist
		# download from sourceforge
		echo "Downloading from SourceForge: $wxWidgetsZip"
		Invoke-WebRequest $source -OutFile $zipfile
	}
}

$buildDir = "$PSScriptRoot/build"

#If !exists Then create build directory
if (!(Test-Path $buildDir)){
	New-Item $buildDir -ItemType directory 
}

Function UnzipWX
{
    unzip "$buildDir/$wxWidgetsZip" -d "$buildDir/wxWidgets"
}

DownloadWX "$buildDir\$wxWidgetsZip"
UnzipWX


