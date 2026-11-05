$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$godotPath = Join-Path $projectRoot '.tools\godot\Godot_v4.7.2-stable_win64.exe'

if (-not (Test-Path -LiteralPath $godotPath)) {
    throw "Godot was not found at $godotPath"
}

& $godotPath --path $projectRoot

