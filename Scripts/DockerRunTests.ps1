$artifactUrl = Get-BCArtifactUrl -version 28 -country base # Docker sandbox does not currently work
$containerName = 'red-multiplelay'
$credential = New-Object pscredential 'admin', (ConvertTo-SecureString -String 'Admin!101' -AsPlainText -Force)
$licenseFile = 'X:\Sync\Red and Bundle\Licenties\BC20 On Prem ForNAV + Own Objects.flf'

New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -artifactUrl $artifactUrl `
    -Credential $credential `
    -auth UserPassword `
    -licenseFile $licenseFile `
    -updateHosts `
    -includeTestToolkit `
    -EnableTaskScheduler false

Publish-BcContainerApp -packageType Extension -appFile 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\Red and Bundle_Multiple Report Layout Selector_2.1.0.0.app' -containerName $containerName -skipVerification
Sync-BcContainerApp -appName "Multiple Report Layout Selector" -Force -containerName $containerName
Install-BcContainerApp -appName "Multiple Report Layout Selector" -containerName $containerName

Publish-BcContainerApp -packageType Extension -appFile 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\Red and Bundle_Red.MultipleLayouts.Test_2.1.0.0.app' -containerName $containerName -skipVerification
Sync-BcContainerApp -appName "Red.MultipleLayouts.Test" -Force -containerName $containerName
Install-BcContainerApp -appName "Red.MultipleLayouts.Test" -containerName $containerName

Run-TestsInNavContainer -containerName $containerName -credential $credential -detailed -testSuite 'REDMULTI'
