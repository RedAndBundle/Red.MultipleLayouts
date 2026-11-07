$artifactUrl = Get-BCArtifactUrl -version 28 -type OnPrem -country w1 -select Latest
$containerName = 'bc-multi'
$credential = New-Object pscredential 'admin', (ConvertTo-SecureString -String 'admin' -AsPlainText -Force)
$licenseFile = 'X:\Onedrive\Red And Bundle\Development - Documents\Licenses\Business Central\BC23 On Prem ForNAV + Own Objects.bclicense'

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
