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


#remove non-essential environment variables from this PS sesssion
function RemoveEnvironment
{
	$keep = @("PATH","ALLUSERSPROFILE","APPDATA","CLIENTNAME","COMMONPROGRAMFILES","COMMONPROGRAMFILES(X86)","COMMONPROGRAMW6432","COMPUTERNAME","COMSPEC","LOCALAPPDATA","NUMBER_OF_PROCESSORS","OS","PATHEXT","PROCESSOR_ARCHITECTURE","PROCESSOR_ARCHITEW6432","PROCESSOR_IDENTIFIER","PROCESSOR_LEVEL","PROCESSOR_REVISION","PROGRAMDATA","PROGRAMFILES","PROGRAMFILES(X86)","PROGRAMW6432","PSMODULEPATH","PUBLIC","SYSTEMDRIVE","SYSTEMROOT","TEMP","TMP","TIME","USERNAME","USERPROFILE","WINDIR","WINDOWS_TRACING_FLAGS","WINDOWS_TRACING_LOGFILE","DATE","ERRORLEVEL","HIGHESTNUMANODENUMBER","HOMEDRIVE","HOMEPATH","LOGONSERVER","SYSTEM","PROMPT","USERDNSDOMAIN","USERDOMAIN")

	foreach ($e in (Get-ChildItem Env:)) {
		$key = $($e.key)
		if (!($keep -contains $key)) {
		(Remove-Item Env:\$key)
		}
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


Function GhcGitDownload ($file) {
    #download if download does not exist
    if (!(Test-Path "$env:DownloadDir\$file")){
		Write-Host "Downloading from http://git.haskell.org/ghc-tarballs.git/: $file"
		Invoke-WebRequest "http://git.haskell.org/ghc-tarballs.git/blob/e7b7b152083f7c3e3559e557a239757d41ac02a6:/mingw/$file" -OutFile "$env:DownloadDir\$file"
    }	
}

Function GhcGitDownload64 ($file) {
    #download if download does not exist
    if (!(Test-Path "$env:DownloadDir\$file")){
		Write-Host "Downloading from http://git.haskell.org/ghc-tarballs.git/: $file"
		Invoke-WebRequest "http://git.haskell.org/ghc-tarballs.git/blob/18e0c37f8023abf469af991e2fc2d3b024319c27:/mingw64/$file" -OutFile "$env:DownloadDir\$file"
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

Function DownloadWxConfigCpp {
    #download if download does not exist
    if (!(Test-Path "$env:DownloadDir\wx-config.cpp")){
		Write-Host "Downloading wx-config.cpp"
		Invoke-WebRequest "https://raw.githubusercontent.com/wxHaskell/wxHaskell/51fd321de8d1a6a369120ee0292db1fa4d08dc28/wx-config-win/wx-config-win/wx-config.cpp" -OutFile "$env:DownloadDir\wx-config.cpp"
    }	
}

Function CreateDirectoryIfNotExist ($dire) {
  if (!(Test-Path $dire)){
	  New-Item $dire -ItemType directory 
  }
}

Function UnzipFile ($zipfile, $dest) {
  $shell = new-object -com shell.application
  $zip = $shell.NameSpace($zipfile)
  
  CreateDirectoryIfNotExist $dest
  
  $destinationFolder = $shell.NameSpace($dest)
  $destinationFolder.CopyHere($zip.Items())
}

Function UnzipIfNotExist ($zip, $dest) 
{
 #unzip if folder does not exist
    if (!(Test-Path $dest)){
     # unzip $zip -d $dest
	 
	 UnzipFile $zip $dest
	 
	}
}

Function Un7 ($zipfile, $output)
{
 $curr = (Get-Location).Path
 $tarfile = $zipfile -replace ".lzma", "" -replace ".gz", "" -replace ".bz2", ""
 
 Invoke-Expression "& '$env:zip7\7z' -y x $env:DownloadDir\$zipfile -o$env:Temp"
 cd $env:Temp
 Invoke-Expression "& '$env:zip7\7z' -y x $tarfile -o$output"
 cd $curr
}

function getWxHaskellHex {	
  return "69671b4cac125a502cabca544f5de040940cc5b6"
}

function wxHaskellDownload ($wxHaskellHex, $wxHaskellPath) {	
	$source = "https://github.com/wxHaskell/wxHaskell/archive/$wxHaskellHex.zip"
    $wxHaskellFile = "wxHaskell_$wxHaskellHex"
	#download wxHaskell from Github
	if (!(Test-Path "$env:DownloadDir\$wxHaskellFile")){
		
			Write-Host "Downloading $source"
			Invoke-WebRequest $source -OutFile "$env:DownloadDir\$wxHaskellFile"
	}

	 #unzip if folder does not exist
    if (!(Test-Path "$wxHaskellPath\wxHaskell-$wxHaskellHex")){
      UnzipFile "$env:DownloadDir/$wxHaskellFile" $wxHaskellPath
	}
	
}
Export-ModuleMember -Alias * -Function *