param(
    [switch]$Write
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $repoRoot "godot/android/build/config.gradle"

if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Godot Android build template is missing. Install the 4.6.3 template before preparing Android export."
}

$content = [IO.File]::ReadAllText($configPath)
$requiredVersion = "kotlinVersion      : '2.3.0'"
if ($content.Contains($requiredVersion)) {
    Write-Output "Android build template is ready (Kotlin 2.3.0)."
    exit 0
}

$pattern = "kotlinVersion\s*:\s*'[^']+'"
if (-not [Text.RegularExpressions.Regex]::IsMatch($content, $pattern)) {
    throw "Could not locate kotlinVersion in $configPath"
}

if (-not $Write) {
    throw "Android template needs Kotlin 2.3.0. Re-run with -Write."
}

$updated = [Text.RegularExpressions.Regex]::Replace($content, $pattern, $requiredVersion, 1)
[IO.File]::WriteAllText($configPath, $updated, [Text.UTF8Encoding]::new($false))
Write-Output "Android build template updated to Kotlin 2.3.0."
