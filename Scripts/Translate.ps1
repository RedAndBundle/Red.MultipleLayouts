Import-Module 'C:\Program Files\Reports ForNAV\ForNav.Cmdlet.dll'

# Set-Location -Path $PSScriptRoot

Invoke-ExportTranslationFromXlfToExcel `
    -FromXlf '.\Red.MultipleLayouts\Translations\'`
    -ToExcel '.\Scripts\Translations-Generated.xlsx'

Invoke-ImportTranslationFromExcelToXlf `
    -FromXlf '.\Red.MultipleLayouts\Translations\Multiple Report Layout Selector.g.xlf'`
    -FromExcel '.\Scripts\Translations.xlsx'`
    -ToXlf '.\Red.MultipleLayouts\Translations'