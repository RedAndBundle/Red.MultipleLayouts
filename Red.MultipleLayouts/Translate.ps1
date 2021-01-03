Import-Module 'C:\Program Files\Reports ForNAV\ForNav.Cmdlet.dll'

Invoke-ExportTranslationFromXlfToExcel `
    -FromXlf 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Red.MultipleLayouts\Translations\Multiple Report Layout Selector.g.xlf'`
    -ToExcel 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Red.MultipleLayouts\Translations.xlsx'

Invoke-ImportTranslationFromExcelToXlf `
    -FromXlf 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Red.MultipleLayouts\Translations\Multiple Report Layout Selector.g.xlf'`
    -FromExcel 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Red.MultipleLayouts\Translations.xlsx'`
    -ToXlf 'X:\Sync\Red and Bundle\Development\Source Code\Red.MultipleLayouts\Red.MultipleLayouts\Translations'