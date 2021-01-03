
Set-Location "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin"

.\SignTool.exe sign /f 'X:\Sync\Red and Bundle\Development\Code Signing\info@redandbundle_com\info@redandbundle_com.pfx' /p CertPass /t http://timestamp.verisign.com/scripts/timestamp.dll 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Red.MultipleLayouts\Red and Bundle_Multiple Report Layout Selector_2.0.0.0.app'