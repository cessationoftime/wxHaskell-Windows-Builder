
$wxWidgetsVersion="3.0.2"
$wxWidgetsZip="wxWidgets-$wxWidgetsVersion.zip"

#setup parameters for Sourceforge download
$timestamp=[Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
$parameterR="http%3A%2F%2Fsourceforge.net%2Fprojects%2Fwxwindows%2Ffiles%2F$wxWidgetsVersion%2F$wxWidgetsZip%2Fdownload"
$parameters="?r=$parameterR&use_mirror=autoselect&ts=$timestamp"
$source = "http://downloads.sourceforge.net/project/wxwindows/$wxWidgetsVersion/$wxWidgetsZip$parameters"
$destination = "$PSScriptRoot/build"

#create the build directory
New-Item $destination -ItemType directory 



Function DownloadWX
{
	#download from sourceforge
	echo "Downloading from SourceForge: $wxWidgetsZip"
	Invoke-WebRequest $source -OutFile "$destination\$wxWidgetsZip"
}

Function UnzipWX
{
    unzip "$destination/$wxWidgetsZip" -d "$destination/wxWidgets"
}

DownloadWX
UnzipWX


