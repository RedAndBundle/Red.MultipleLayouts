# https://freddysblog.com/2021/01/03/how-to-use-run-alvalidation/

# install-module bccontainerhelper -force -AllowClobber
# uninstall-module navcontainerhelper -force

# $licenseFile = 'X:\OneDrive\Red And Bundle B.V\Development - Documents\Licenses\Business Central\BC25 On Prem ForNAV + Own Objects.bclicense'
# ForNAV apps are only needed because the previous release ($prev) still depends on the ForNAV Customizable Report Pack.
# The current app has no ForNAV dependency; drop these (and -installApps) once $prev is a ForNAV-free release.
$fnLanguage = "X:\SourceCode\Cust.ForNAV\ForNAV Docker Installer\UniversalCodeApp 25\ForNAV Language Module 8.0.2500.3.app"
$fnCore = "X:\SourceCode\Cust.ForNAV\ForNAV Docker Installer\UniversalCodeApp 25\ForNAV Core 8.0.2500.3.app"
$fnReport = "X:\SourceCode\Cust.ForNAV\ForNAV Docker Installer\UniversalCodeApp 25\ForNAV Customizable Report Pack 8.0.2500.3.app"
$app = "X:\SourceCode\Red.MultipleLayouts\_Build\Red and Bundle_Multiple Report Layout Selector_3.3.0.0.app"
$prev = "X:\SourceCode\Red.MultipleLayouts\_Build Archive\Red and Bundle_Multiple Report Layout Selector_3.2.0.0.app"


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