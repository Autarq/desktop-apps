param (
    [System.Version]$Version = "0.0.0.0",
    [string]$Arch = "x64",
    [string]$Target,
    [string]$CompanyName = "AUTARQ",
    [string]$ProductName = "Office",
    [string]$BuildDir
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

if (-not $BuildDir) {
    $BuildDir = "build\$Arch"
}
if (-not (Test-Path "$BuildDir")) {
    Write-Error "Path `"$BuildDir`" does not exist"
}
$ResolvedBuildDir = (Resolve-Path -LiteralPath "$BuildDir").ProviderPath
$ZipFile = switch ($Target) {
    "commercial" { "$CompanyName-$ProductName-Enterprise-$Version-$Arch.zip" }
    "xp"         { "$CompanyName-$ProductName-XP-$Version-$Arch.zip" }
    default      { "$CompanyName-$ProductName-$Version-$Arch.zip" }
}

Write-Host @"
Version     = $Version
Arch        = $Arch
Target      = $Target
CompanyName = $CompanyName
ProductName = $ProductName
BuildDir    = $BuildDir
ZipFile     = $ZipFile
"@

####

Write-Host "`n[ Create archive ]"

$ZipDir = Join-Path $PSScriptRoot "zip"
$ZipPath = Join-Path $ZipDir $ZipFile
New-Item -ItemType Directory -Force -Path $ZipDir | Out-Null

if (Test-Path -LiteralPath "$ZipPath") {
    Write-Host "DELETE: $ZipPath"
    Remove-Item -Force -LiteralPath "$ZipPath"
}

function Add-ArchiveContent {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SourceDir
    )

    if (-not (Test-Path -LiteralPath "$SourceDir")) {
        throw "Path `"$SourceDir`" does not exist"
    }

    Push-Location "$SourceDir"
    try {
        Write-Host "7z a -y $ZipPath *"
        & 7z a -y "$ZipPath" "*"
        if ($LastExitCode -ne 0) { throw }
    }
    finally {
        Pop-Location
    }
}

Add-ArchiveContent -SourceDir (Join-Path $ResolvedBuildDir "desktop")

if ($Target -eq "standalone" -or $Target -eq "xp") {
    Add-ArchiveContent -SourceDir (Join-Path $ResolvedBuildDir "help")
}
