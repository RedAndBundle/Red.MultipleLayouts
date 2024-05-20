<#
.SYNOPSIS
   Installs all app files from a folder onto a Docker instance
.DESCRIPTION
   This script will copy all app files to a docker container
   if there is a .ps1 file in the directory it is run
.EXAMPLE
   ./InstallAppsOnDocker.ps1 -Project ./Core -Output fornav_core.app
.EXAMPLE
   ./build_app.ps1 -Project './Report Pack' -Output fornav_report_pack.app
#>
param(
    # containerName = the docker container
    [Parameter(Mandatory = $true)]
    [String]
    $containerName,

    # buildfolder is the folder containing the app files
    [Parameter(Mandatory = $true)]
    [String]
    $buildFolder,

    # installfolder is the folder that will be created on the root of the docker server
    [Parameter(Mandatory = $true)]
    [String]
    $installFolder
)

$files = Get-ChildItem $buildFolder
$fnRuntimeInstallFile = "";

$cmd = "Remove-Item C:\$installFolder -Recurse -ErrorAction Ignore"
docker exec $containerName powershell -command $cmd

$tmpFolder = New-Item -Path $buildFolder -Name $installFolder -ItemType "directory"

for ($i=0; $i -lt $files.Count; $i++) {
    Copy-Item $files[$i].FullName -Destination $tmpFolder
    if ($files[$i].Extension -eq ".ps1") { $fnRuntimeInstallFile = $files[$i].Name }
}

$dest = "{0}:\{1}" -f $containerName, $installFolder
docker cp $tmpFolder $dest
Remove-Item $tmpFolder -Recurse

if ($fnRuntimeInstallFile -ne "") {
    $cmd = "C:\{0}\{1}" -f $installFolder, $fnRuntimeInstallFile
    docker exec $containerName powershell -command $cmd
}
