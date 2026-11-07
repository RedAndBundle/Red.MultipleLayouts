<#
.SYNOPSIS
    Signs the .app files in _Build with Azure Artifact Signing (formerly Trusted Signing).
.DESCRIPTION
    Uses Windows SDK signtool.exe (x64) with the Artifact Signing dlib. The signing account and
    certificate profile are read from ArtifactSigning.json next to this script.

    Prerequisites (one-time):
      - Windows SDK signtool 10.0.22621 or later (x64). The 20348 SDK is not supported by the dlib.
      - .NET 8 runtime and the Visual C++ x64 redistributable.
      - NavSip.dll registered for x64 (C:\Windows\System32\NavSip.dll) so signtool can sign BC .app files.
      - The "Artifact Signing Certificate Profile Signer" role on the certificate profile.
      - Signed in with the Azure CLI: az login
    The dlib (NuGet package Microsoft.ArtifactSigning.Client) is downloaded automatically into
    %LOCALAPPDATA%\RedAndBundle\ArtifactSigning on first use.
.EXAMPLE
    .\Scripts\Codesign.ps1
.EXAMPLE
    .\Scripts\Codesign.ps1 -BuildFolder 'C:\temp\apps'
#>
[CmdletBinding()]
param(
    [string] $BuildFolder = (Join-Path $PSScriptRoot '..\_Build'),
    [string] $MetadataFile = (Join-Path $PSScriptRoot 'ArtifactSigning.json'),
    [string] $DlibVersion = '1.0.128',
    [string] $TimestampUrl = 'http://timestamp.acs.microsoft.com'
)

$ErrorActionPreference = 'Stop'

function Get-SignTool {
    $kits = 'C:\Program Files (x86)\Windows Kits\10\bin'
    $tool = Get-ChildItem $kits -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' -and [version]$_.Name -ge [version]'10.0.22621.0' } |
        Sort-Object { [version]$_.Name } -Descending |
        ForEach-Object { Join-Path $_.FullName 'x64\signtool.exe' } |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1
    if (-not $tool) { throw "signtool.exe (x64, Windows SDK 10.0.22621 or later) not found under '$kits'. Install the Windows SDK signing tools." }
    $tool
}

function Get-ArtifactSigningDlib([string] $Version) {
    $root = Join-Path $env:LOCALAPPDATA "RedAndBundle\ArtifactSigning\$Version"
    $dlib = Get-ChildItem $root -Recurse -Filter 'Azure.CodeSigning.Dlib.dll' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\\x64\\' } | Select-Object -First 1
    if ($dlib) { return $dlib.FullName }

    Write-Host "Downloading Microsoft.ArtifactSigning.Client $Version ..."
    New-Item -ItemType Directory -Force $root | Out-Null
    $zip = Join-Path $root 'package.zip'
    Invoke-WebRequest "https://www.nuget.org/api/v2/package/Microsoft.ArtifactSigning.Client/$Version" -OutFile $zip
    Expand-Archive $zip -DestinationPath $root -Force
    Remove-Item $zip

    $dlib = Get-ChildItem $root -Recurse -Filter 'Azure.CodeSigning.Dlib.dll' |
        Where-Object { $_.FullName -match '\\x64\\' } | Select-Object -First 1
    if (-not $dlib) { throw "Azure.CodeSigning.Dlib.dll (x64) not found in the Microsoft.ArtifactSigning.Client $Version package." }
    $dlib.FullName
}

# --- checks -------------------------------------------------------------------
if (-not (Test-Path $MetadataFile)) { throw "Metadata file '$MetadataFile' not found." }
$metadata = Get-Content $MetadataFile -Raw | ConvertFrom-Json
if ($metadata.CertificateProfileName -match '^<.*>$' -or [string]::IsNullOrWhiteSpace($metadata.CertificateProfileName)) {
    throw "Set CertificateProfileName in '$MetadataFile' to the certificate profile of account '$($metadata.CodeSigningAccountName)'."
}

if (-not (Test-Path "$env:windir\System32\NavSip.dll")) {
    throw "NavSip.dll is not installed for x64. Copy it from a BC service folder to C:\Windows\System32 and run: regsvr32 C:\Windows\System32\NavSip.dll"
}

az account show --only-show-errors 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Not signed in to Azure. Run 'az login' first." }

$files = @(Get-ChildItem $BuildFolder -Filter *.app)
if ($files.Count -eq 0) { throw "No .app files found in '$BuildFolder'." }

$signTool = Get-SignTool
$dlibPath = Get-ArtifactSigningDlib $DlibVersion
Write-Host "signtool: $signTool"
Write-Host "dlib:     $dlibPath"
Write-Host "profile:  $($metadata.CodeSigningAccountName) / $($metadata.CertificateProfileName)"

# --- sign + verify ------------------------------------------------------------
$paths = $files.FullName
& $signTool sign /v /fd SHA256 /tr $TimestampUrl /td SHA256 /dlib $dlibPath /dmdf (Resolve-Path $MetadataFile).Path $paths
if ($LASTEXITCODE -ne 0) { throw "signtool sign failed with exit code $LASTEXITCODE." }

& $signTool verify /pa $paths
if ($LASTEXITCODE -ne 0) { throw "signtool verify failed with exit code $LASTEXITCODE." }

Write-Host "Signed $($files.Count) file(s) in $BuildFolder" -ForegroundColor Green
