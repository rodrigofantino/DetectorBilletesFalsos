param(
    [switch]$Write
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $repoRoot "godot/android/build/config.gradle"
$buildGradlePath = Join-Path $repoRoot "godot/android/build/build.gradle"
$proguardRulesPath = Join-Path $repoRoot "godot/android/build/proguard-rules.pro"

if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Godot Android build template is missing. Install the 4.6.3 template before preparing Android export."
}

$content = [IO.File]::ReadAllText($configPath)
$requiredVersion = "kotlinVersion      : '2.3.0'"
$pattern = "kotlinVersion\s*:\s*'[^']+'"
$needsKotlinUpdate = -not $content.Contains($requiredVersion)
if ($needsKotlinUpdate) {
    if (-not [Text.RegularExpressions.Regex]::IsMatch($content, $pattern)) {
        throw "Could not locate kotlinVersion in $configPath"
    }
    if (-not $Write) {
        throw "Android template needs Kotlin 2.3.0. Re-run with -Write."
    }
    $updated = [Text.RegularExpressions.Regex]::Replace($content, $pattern, $requiredVersion, 1)
    [IO.File]::WriteAllText($configPath, $updated, [Text.UTF8Encoding]::new($false))
    Write-Output "Android build template updated to Kotlin 2.3.0."
} else {
    Write-Output "Android build template is ready (Kotlin 2.3.0)."
}

if (-not (Test-Path -LiteralPath $buildGradlePath -PathType Leaf)) {
	throw "Generated Android Gradle project is missing: $buildGradlePath. Export the Android Gradle project once, then rerun with -Write."
}

$buildContent = [IO.File]::ReadAllText($buildGradlePath)
if (-not $buildContent.Contains("minifyEnabled true")) {
	if (-not $Write) {
		throw "Release R8 optimization is not enabled. Re-run with -Write."
	}
	$releasePattern = '(?ms)(^\s*release\s*\{\r?\n)'
	if (-not [Text.RegularExpressions.Regex]::IsMatch($buildContent, $releasePattern)) {
		throw "Could not locate the release build type in $buildGradlePath"
	}
	$replacement = '$1' + [Environment]::NewLine + "            minifyEnabled true" + [Environment]::NewLine + "            shrinkResources true" + [Environment]::NewLine + "            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'" + [Environment]::NewLine
	$buildContent = [Text.RegularExpressions.Regex]::Replace($buildContent, $releasePattern, $replacement, 1)
	[IO.File]::WriteAllText($buildGradlePath, $buildContent, [Text.UTF8Encoding]::new($false))
	Write-Output "Release R8 optimization enabled in generated Android Gradle project."
} else {
	Write-Output "Release R8 optimization already enabled."
}

if (-not (Test-Path -LiteralPath $proguardRulesPath -PathType Leaf)) {
	if (-not $Write) {
		throw "Project-specific R8 rules file is missing. Re-run with -Write."
	}
	$rules = @"
# Project-specific R8 rules.
# Android plugins contribute their own consumer rules; keep this file for
# app-specific reflection rules discovered during release testing.
"@
	[IO.File]::WriteAllText($proguardRulesPath, $rules, [Text.UTF8Encoding]::new($false))
	Write-Output "Created empty project-specific R8 rules file."
}
