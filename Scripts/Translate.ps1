Import-Module 'C:\Program Files\Reports ForNAV\ForNav.Cmdlet.dll'

# Set-Location -Path $PSScriptRoot

Invoke-ExportTranslationFromXlfToExcel `
    -FromXlf 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Red.MultipleLayouts\Translations\Multiple Report Layout Selector.g.xlf'`
    -ToExcel 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Scripts\Translations-Generated.xlsx'

Invoke-ImportTranslationFromExcelToXlf `
    -FromXlf 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Red.MultipleLayouts\Translations\Multiple Report Layout Selector.g.xlf'`
    -FromExcel 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Scripts\Translations.xlsx'`
    -ToXlf 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Red.MultipleLayouts\Translations'