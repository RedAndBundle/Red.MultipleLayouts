$BuildFolder = "X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build"
$files = Get-ChildItem $BuildFolder -Filter *.app

Set-Location "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin"

for ($i=0; $i -lt $files.Count; $i++) {
    $outfile = $files[$i].FullName
   .\SignTool.exe sign /n 'Red and Bundle' /t http://timestamp.comodoca.com/authenticode $outfile
}

# Use Safenet toen password from Bitwarden: Sectigo token password
# Install safenet token client from https://www.sectigo.com/knowledge-base/detail/SafeNet-Authentication-Client-Download-for-Sectigo-Certificates-on-eToken/kA03l000000o6kL