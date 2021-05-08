# https://freddysblog.com/2021/01/03/how-to-use-run-alvalidation/

# install-module bccontainerhelper -force -AllowClobber
# uninstall-module navcontainerhelper -force

$licenseFile = 'X:\Sync\Red and Bundle\Licenties\BC18 On Prem ForNAV + Own Objects.flf'

Run-AlValidation `
    -licenseFile $licenseFile `
    -installApps @("X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output\ForNAV_Language_Module_6.0.0.0.app", "X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output\ForNAV_ForNAV Core_6.0.0.0.app", "X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output\ForNAV_Customizable Report Pack_6.0.0.0.app") `
    -apps @("X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\Red and Bundle_Multiple Report Layout Selector_2.0.0.0.app") `
    -affixes "red" `
    -countries @("nl", "de", "dk")

    # -countries @("us", "nl", "de", "dk") US not on BC 18 yet

    # -installApps @("X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output\ForNAV_Language_Module_6.0.0.0.app", "X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output\ForNAV_ForNAV Core_6.0.0.0.app", "X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output\ForNAV_Customizable Report Pack_6.0.0.0.app") `
    # -installApps @("X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output\ForNAV_ForNAV Language Module_6.0.0.0.app", "X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output\ForNAV_ForNAV Core_6.0.0.0.app", "X:\Sync\Red and Bundle\Klanten\ForNAV\Source Code\ForNav.ReportPack\_output\ForNAV_Customizable Report Pack_6.0.0.0.app") `