param(
    [string]$GodotPath = "$env:USERPROFILE/Tools/Godot463/Godot_v4.6.3-stable_win64_console.exe",
    [switch]$VerboseEngine
)

$ErrorActionPreference = 'Stop'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('run-with-me-evening-tests-' + [guid]::NewGuid().ToString('N'))
$gameProject = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$oldAppData = $env:APPDATA
$result = 1
try {
    $env:APPDATA = Join-Path $testRoot 'userdata'
    New-Item -ItemType Directory -Path $env:APPDATA -Force | Out-Null
    # A clean checkout has source art but no imported textures or script cache.
    & $GodotPath --headless --editor --import --path $gameProject --log-file (Join-Path $testRoot 'import.log')
    if ($LASTEXITCODE -ne 0) { throw 'Godot asset import failed before the flow test.' }
    $godotArguments = @('--headless', '--path', $gameProject, '--script', 'res://tests/evening_flow_test.gd', '--log-file', (Join-Path $testRoot 'flow.log'))
    if ($VerboseEngine) { $godotArguments += '--verbose' }
    & $GodotPath @godotArguments
    $result = $LASTEXITCODE
}
finally {
    $env:APPDATA = $oldAppData
    $resolvedTest = [System.IO.Path]::GetFullPath($testRoot)
    $resolvedTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if ($resolvedTest.StartsWith($resolvedTemp, [System.StringComparison]::OrdinalIgnoreCase) -and ([System.IO.Path]::GetFileName($resolvedTest)).StartsWith('run-with-me-evening-tests-')) {
        Remove-Item -LiteralPath $resolvedTest -Recurse -Force -ErrorAction SilentlyContinue
    }
}
exit $result
