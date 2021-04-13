$WarningPreference = 'SilentlyContinue'
$BCVersion = "180"
$version = "2.0.0.0"
#$WarningPreference = 'Continue'
#$navmodule = "C:\Program Files\Microsoft Dynamics 365 Business Central\" + $BCVersion + "\Service\NavAdminTool.ps1"
$navmodule = "C:\Program Files\Microsoft Dynamics NAV\" + $BCVersion + "\Service\NavAdminTool.ps1"
Import-Module $navmodule -WarningAction SilentlyContinue | Out-Null
Set-Location -Path $PSScriptRoot
#$instance = "BC" + $BCVersion
$instance = "BC"


function InstallApplication($path, $name)
{
    "  $name"
    $apps = Get-NAVAppInfo -ServerInstance $instance -Name $name
    foreach ($app in $apps)
    {
        if ($app.Publisher -eq "Red and Bundle")
        {
            "  " + $app.Name
            "    Uninstall"
            Uninstall-NAVApp -ServerInstance $instance -Name $app.Name -Force
            "    Sync"
            Sync-NAVApp -ServerInstance $instance -Name $app.Name -Mode Clean -Force
            "    Unpublish"
            Unpublish-NAVApp -ServerInstance $instance -Name $app.Name -Version $app.Version -ErrorAction SilentlyContinue -ErrorVariable err
        }
	}

    Publish-NAVApp -ServerInstance $instance -SkipVerification -Path $path
    "    Sync clean"
    Sync-NAVApp -ServerInstance $instance -Name $name -Mode Clean -Force -ErrorAction SilentlyContinue -ErrorVariable err
    "    Sync force"
    Sync-NAVApp -ServerInstance $instance -Name $name -Mode ForceSync -Force  -ErrorAction SilentlyContinue -ErrorVariable err
    "    Install"
    Install-NAVApp -ServerInstance $instance -Name $name
}

InstallApplication ".\Red and Bundle_Multiple Report Layout Selector_$version.app" 'Multiple Report Layout Selector'
InstallApplication ".\Red and Bundle_Red.MultipleLayouts.Test_$version.app" 'Red.MultipleLayouts.Test'
