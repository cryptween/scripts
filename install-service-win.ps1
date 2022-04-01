# Download latest dotnet/codeformatter release from github

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

$repo = "cryptween/scripts"
$file = "cryptween-daemon-win.exe"
$Program = "cryptween"

$releases = "https://api.github.com/repos/$repo/releases"

Write-Host Determining latest release
$tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name

$downloadUrl = "https://github.com/$repo/releases/download/$tag/$file"
Write-Host $downloadUrl

#Let's check is OS 32 or 64 bit
if ([environment]::Is64BitOperatingSystem) {
    $installationPath = $env:ProgramFiles
}
else {
    $installationPath = ${env:ProgramFiles(x86)}
}

#Let's check is there old installation folder
$ProgramPath = Join-Path -Path $installationPath -ChildPath "\$Program\"
<# $Programtest = Test-Path $ProgramPath

Write-Host $ProgramPath
If ($Programtest -eq $false ) {
    Write-Host "None found, let's continue the installation" 
    $null = new-item -itemType directory -path "$ProgramPath" 
    write-host "directory was created"
}
Else { 
    Write-Host "Old installation folder found, removing files" 
    Get-ChildItem -Path $ProgramPath -Include *.* -Recurse | ForEach-Object { $_.Delete()}
}

Invoke-WebRequest -Uri $downloadUrl -OutFile $ProgramPath/$file #>

# Install service
$serviceName = $Program
# verify if the service already exists, and if yes remove it first
If (Get-Service $serviceName -ErrorAction SilentlyContinue)
{
    $serviceToRemove = Get-WmiObject -Class Win32_Service -Filter "name='$serviceName'"
    $serviceToRemove.delete()
    "service removed"
}
Else
{
    "service does not exists"
}

"installing service"

#$secpasswd = ConvertTo-SecureString "MyPassword" -AsPlainText -Force
#$mycreds = New-Object System.Management.Automation.PSCredential (".\MYUser", $secpasswd)
$binaryPath = "$ProgramPath/$file"
#New-Service -name $serviceName -binaryPathName $binaryPath -displayName $serviceName 
#-startupType Automatic -credential $mycreds
New-Service -name $serviceName -binaryPathName $binaryPath -displayName $serviceName `
    -startupType Automatic -Description "cryptween daemon"

"installation completed NOT WORKING"