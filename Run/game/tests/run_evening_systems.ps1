param(
    [string]$GodotPath = "$env:USERPROFILE/Tools/Godot463/Godot_v4.6.3-stable_win64_console.exe"
)

$ErrorActionPreference = 'Stop'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('run-with-me-evening-tests-' + [guid]::NewGuid().ToString('N'))
$testProject = Join-Path $testRoot 'project'
$oldAppData = $env:APPDATA
$result = 1
try {
    New-Item -ItemType Directory -Path (Join-Path $testProject 'scripts/evening') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $testProject 'tests') -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot '../scripts/evening/EveningSave.gd') -Destination (Join-Path $testProject 'scripts/evening/EveningSave.gd')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot '../scripts/evening/EveningSound.gd') -Destination (Join-Path $testProject 'scripts/evening/EveningSound.gd')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'evening_systems_test.gd') -Destination (Join-Path $testProject 'tests/evening_systems_test.gd')
    @'
config_version=5
[application]
config/name="Run With Me M1 System Tests"
[rendering]
renderer/rendering_method="gl_compatibility"
'@ | Set-Content -LiteralPath (Join-Path $testProject 'project.godot') -Encoding utf8
    $env:APPDATA = Join-Path $testRoot 'userdata'
    New-Item -ItemType Directory -Path $env:APPDATA -Force | Out-Null
    & $GodotPath --headless --path $testProject --script res://tests/evening_systems_test.gd
    $result = $LASTEXITCODE
}
finally {
    $env:APPDATA = $oldAppData
    # Keep this wrapper ASCII for Windows PowerShell 5.1 without a UTF-8 BOM.
    # Only remove this run's resolved directory within the system temp root.
    $resolvedTest = [System.IO.Path]::GetFullPath($testRoot)
    $resolvedTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if ($resolvedTest.StartsWith($resolvedTemp, [System.StringComparison]::OrdinalIgnoreCase) -and ([System.IO.Path]::GetFileName($resolvedTest)).StartsWith('run-with-me-evening-tests-')) {
        Remove-Item -LiteralPath $resolvedTest -Recurse -Force -ErrorAction SilentlyContinue
    }
}
exit $result
