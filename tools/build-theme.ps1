[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$themeRoot = Join-Path $projectRoot 'src/opnsense/www/themes/opnfluent/build/css'
$mainPath = Join-Path $themeRoot 'main.css'
$overlayPath = Join-Path $themeRoot 'fluent-mica.css'
$marker = '/* === OPNfluent Mica overlay (generated) === */'

$main = [IO.File]::ReadAllText($mainPath)
$markerIndex = $main.IndexOf($marker, [StringComparison]::Ordinal)
if ($markerIndex -ge 0) {
    $main = $main.Substring(0, $markerIndex).TrimEnd()
}

$overlay = [IO.File]::ReadAllText($overlayPath).Trim()
$bundle = $main + [Environment]::NewLine + [Environment]::NewLine + $marker +
    [Environment]::NewLine + $overlay + [Environment]::NewLine
[IO.File]::WriteAllText($mainPath, $bundle, [Text.UTF8Encoding]::new($false))

Write-Host "Bundled fluent-mica.css into main.css"
