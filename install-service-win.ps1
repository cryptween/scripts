# Download latest dotnet/codeformatter release from github

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

$repo = "cryptween/scripts"
$file = "cryptween-daemon-win.exe"

$releases = "https://api.github.com/repos/$repo/releases"

Write-Host Determining latest release
$tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name

$download = "https://github.com/$repo/releases/download/$tag/$file"
Write-Host $download