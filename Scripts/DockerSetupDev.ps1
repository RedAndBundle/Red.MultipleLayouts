$artifactUrl = Get-BCArtifactUrl -version 23 -type OnPrem -country w1 -select Latest
$containerName = 'bc-multi'
$credential = New-Object pscredential 'admin', (ConvertTo-SecureString -String 'admin' -AsPlainText -Force)
$licenseFile = 'X:\Onedrive\Red And Bundle\Development - Documents\Licenses\Business Central\BC23 On Prem ForNAV + Own Objects.bclicense'
$ucInstallFolder = 'X:\Sync\Red and Bundle\Development\Source Code\Cust.ForNAV\ForNAV Docker Installer\UniversalCodeApp 23'
$appVersion = "7.2.0.0"

New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -artifactUrl $artifactUrl `
    -Credential $credential `
    -auth UserPassword `
    -licenseFile $licenseFile `
    -updateHosts `
    -isolation hyperv `
    -EnableTaskScheduler:$true `
    -useGenericImage "$(Get-BestGenericImageName)-dev" `
    -includeTestToolkit
    
#    -useSSL `

Add-FontsToBCContainer -containerName $containerName -path c:\windows\fonts\*.ttf

Publish-BcContainerApp -packageType Extension -appFile "$ucInstallFolder\ForNAV Language Module $appVersion.app" -containerName $containerName -skipVerification 
Sync-BcContainerApp -appName "ForNAV Language Module" -Force -containerName $containerName
Install-BcContainerApp -appName "ForNAV Language Module" -containerName $containerName

Publish-BcContainerApp -packageType Extension -appFile "$ucInstallFolder\ForNAV Core $appVersion.app" -containerName $containerName -skipVerification 
Sync-BcContainerApp -appName "ForNAV Core" -Force -containerName $containerName
Install-BcContainerApp -appName "ForNAV Core" -containerName $containerName

Publish-BcContainerApp -packageType Extension -appFile "$ucInstallFolder\ForNAV Customizable Report Pack $appVersion.app" -containerName $containerName -skipVerification 
Sync-BcContainerApp -appName "Customizable Report Pack" -Force -containerName $containerName
Install-BcContainerApp -appName "Customizable Report Pack" -containerName $containerName

Publish-BcContainerApp -packageType Extension -appFile "$ucInstallFolder\ForNAV Service (web service) $appVersion.app" -containerName $containerName -skipVerification 
Sync-BcContainerApp -appName "ForNAV Service" -Force -containerName $containerName
Install-BcContainerApp -appName "ForNAV Service" -containerName $containerName

docker stop $containerName
$dest = "{0}:\{1}" -f $containerName, "ForNAVUC"
docker cp $ucInstallFolder $dest
docker start $containerName
Start-Sleep -Seconds 30
docker exec $containerName powershell -command "C:\ForNAVUC\installReportService.ps1"


# -includeTestToolkit `