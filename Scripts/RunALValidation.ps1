# https://freddysblog.com/2021/01/03/how-to-use-run-alvalidation/

# install-module bccontainerhelper -force -AllowClobber
# uninstall-module navcontainerhelper -force

$licenseFile = 'X:\Sync\Red and Bundle\Licenties\BC18 On Prem ForNAV + Own Objects.flf'

Run-AlValidation `
    -licenseFile $licenseFile `
    -installApps @("X:\Data\Report Pack Runtime\ForNAV Service_6.0.0.2057.app", "X:\Data\Report Pack Runtime\ForNAV Language Module_6.0.0.2057.app", "X:\Data\Report Pack Runtime\ForNAV Core_6.0.0.2057.app", "X:\Data\Report Pack Runtime\ForNAV_Customizable Report Pack_6.0.0.2057.app") `
    -apps @("X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\Red and Bundle_Multiple Report Layout Selector_2.0.0.0.app") `
    -affixes "red" `
    -countries "us"

    # -installApps @("X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\ForNAV_Language_Module_5.4.0.1.app", "X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\ForNAV_ForNAV Core_5.4.0.1.app", "X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\ForNAV_Customizable Report Pack_5.4.0.1.app") `
    # -installApps @("X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\ForNAV_ForNAV Language Module_5.4.0.1.app", "X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\ForNAV_ForNAV Core_5.4.0.1.app", "X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\_Build\ForNAV_Customizable Report Pack_5.4.0.1.app") `