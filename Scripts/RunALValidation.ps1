# https://freddysblog.com/2021/01/03/how-to-use-run-alvalidation/

# install-module bccontainerhelper -force -AllowClobber
# uninstall-module navcontainerhelper -force

$licenseFile = 'X:\Onedrive\Red And Bundle\Development - Documents\Licenses\Business Central\BC23 On Prem ForNAV + Own Objects.bclicense'
$fnLanguage = "X:\Sync\Red and Bundle\Development\Source Code\Cust.ForNAV\ForNAV Docker Installer\CB Tenant Layout\ForNAV Language Module 7.3.0.0.app"
$fnCore = "X:\Sync\Red and Bundle\Development\Source Code\Cust.ForNAV\ForNAV Docker Installer\CB Tenant Layout\ForNAV Core 7.3.0.0.app"
$fnReport ="x:\Sync\Red and Bundle\Development\Source Code\Cust.ForNAV\ForNAV Docker Installer\CB Tenant Layout\ForNAV Customizable Report Pack 7.3.0.0.app"
$prev = "X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build Archive\Red and Bundle_Multiple Report Layout Selector_2.1.0.1.app"
$app = "X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\Red and Bundle_Multiple Report Layout Selector_3.0.0.1.app"


# Run-AlValidation `
#     -licenseFile $licenseFile `
#     -installApps @($fnLanguage, $fnCore, $fnReport) `
#     -apps @("X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\Red and Bundle_Multiple Report Layout Selector_2.1.0.0.app") `
#     -affixes "red" `
#     -countries @("nl", "de", "dk", "us")

$validationResults = Run-AlValidation `
    -validateCurrent `
    -installApps @($fnLanguage, $fnCore, $fnReport) `
    -previousApps @( $prev ) `
    -apps @( $app ) `
    -countries @("nl", "de", "dk", "us") `
    -affixes @( "red" ) `
    -supportedCountries @( "nl", "de", "dk", "us" )

$validationResults | Write-Host -ForegroundColor Red