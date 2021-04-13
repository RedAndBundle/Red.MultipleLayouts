# $artifactUrl = Get-BCArtifactUrl -country base // Docker sandbox does not currently work
$artifactUrl = Get-BCArtifactUrl -version 18 -type OnPrem -country w1 -select Latest
$containerName = 'bc18-multiLay'
$credential = New-Object pscredential 'admin', (ConvertTo-SecureString -String 'admin' -AsPlainText -Force)
$licenseFile = 'X:\Sync\Red and Bundle\Licenties\BC18 On Prem ForNAV + Own Objects.flf'

New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -artifactUrl $artifactUrl `
    -Credential $credential `
    -auth UserPassword `
    -licenseFile $licenseFile `
    -includeTestToolkit `
    -updateHosts

Add-FontsToBCContainer -containerName $containerName -path c:\windows\fonts\*.ttf

.\InstallAppsOnDocker.ps1 -containerName $containerName -buildFolder 'X:\Data\Report Pack Runtime' -installFolder 'ForNAVRuntime'
