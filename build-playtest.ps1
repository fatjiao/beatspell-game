$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$godotGui = Join-Path $projectRoot '.tools\godot\Godot_v4.7.2-stable_win64.exe'
$godotConsole = Join-Path $projectRoot '.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$buildRoot = Join-Path $projectRoot 'build\BeatspellPlaytest'
$packPath = Join-Path $buildRoot 'BeatspellPlaytest.pck'
$runnerPath = Join-Path $buildRoot 'BeatspellPlaytest.exe'
$archivePath = Join-Path $projectRoot 'build\BeatspellPlaytest-v0.5.0.zip'

foreach ($required in @($godotGui, $godotConsole)) {
	if (-not (Test-Path -LiteralPath $required)) {
		throw "Missing Godot executable: $required"
	}
}

& $godotConsole --headless --path $projectRoot --script res://tests/run_tests.gd
if ($LASTEXITCODE -ne 0) {
	throw "Automated tests failed with exit code $LASTEXITCODE"
}

New-Item -ItemType Directory -Force -Path $buildRoot | Out-Null
& $godotConsole --headless --path $projectRoot --script res://tests/test_playtest_flow.gd
if ($LASTEXITCODE -ne 0) {
	throw "Playtest flow integration failed with exit code $LASTEXITCODE"
}
foreach ($oldFile in @($packPath, $runnerPath, $archivePath)) {
	if (Test-Path -LiteralPath $oldFile) {
		Remove-Item -LiteralPath $oldFile -Force
	}
}

& $godotConsole --headless --path $projectRoot --export-pack 'Windows Desktop' $packPath
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $packPath)) {
	throw "Godot pack export failed with exit code $LASTEXITCODE"
}

Copy-Item -LiteralPath $godotGui -Destination $runnerPath -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'packaging\Launch Beatspell.cmd') -Destination (Join-Path $buildRoot 'Launch Beatspell.cmd') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'packaging\README.txt') -Destination (Join-Path $buildRoot 'README.txt') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'packaging\GODOT_LICENSE.txt') -Destination (Join-Path $buildRoot 'GODOT_LICENSE.txt') -Force
$fontRoot = Join-Path $projectRoot 'assets\fonts\fusion-pixel'
$fontNotices = Join-Path $buildRoot 'FONT_LICENSES'
New-Item -ItemType Directory -Force -Path $fontNotices | Out-Null
foreach ($notice in @('README.md', 'licenses-8px', 'licenses-10px')) {
	Copy-Item -LiteralPath (Join-Path $fontRoot $notice) -Destination $fontNotices -Recurse -Force
}

& $godotConsole --headless --main-pack $packPath --quit-after 60
if ($LASTEXITCODE -ne 0) {
	throw "Packaged game smoke test failed with exit code $LASTEXITCODE"
}

Compress-Archive -LiteralPath $buildRoot -DestinationPath $archivePath -CompressionLevel Optimal
Write-Output "Built portable playtest: $archivePath"
