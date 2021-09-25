
# $SigntoolPath = "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin"
# Set-Location $PSScriptRoot
# $BuildFolder = Resolve-Path "X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build"
$BuildFolder = "X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build"
# $BuildFolder = "X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output"
$files = Get-ChildItem $BuildFolder -Filter *.app

Set-Location "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin"

for ($i=0; $i -lt $files.Count; $i++) {
    $outfile = $files[$i].FullName
    # .\SignTool.exe sign /f 'X:\Sync\Red and Bundle\Development\Code Signing\info@redandbundle_com\info@redandbundle_com.pfx' /p CertPass /t http://timestamp.globalsign.com/scripts/timstamp.dll $outfile
    # .\SignTool.exe sign /f 'X:\Sync\Red and Bundle\Development\Code Signing\info@redandbundle_com\info@redandbundle_com.pfx' /p CertPass /t http://timestamp.comodoca.com/authenticode $outfile
    .\SignTool.exe sign /f 'X:\Sync\Red and Bundle\Development\Code Signing\support@redandbundle_com\support@redandbundle_com.pfx' /p HBbdofdsbubgIYVIYHVBKhL15983LAo /t http://timestamp.comodoca.com/authenticode $outfile
}