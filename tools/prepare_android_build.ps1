param(
    [switch]$Write
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $repoRoot "godot/android/build/config.gradle"
$buildGradlePath = Join-Path $repoRoot "godot/android/build/build.gradle"
$proguardRulesPath = Join-Path $repoRoot "godot/android/build/proguard-rules.pro"
$manifestPath = Join-Path $repoRoot "godot/android/build/src/main/AndroidManifest.xml"

if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Godot Android build template is missing. Install the 4.6.3 template before preparing Android export."
}

# Older generated Gradle projects can retain the pre-rename BillScan plugin
# manifest even after the source AAR moved from billscan to billrecognition.
# That leaves both plugin entry points in the merged manifest and can make the
# release process die before the Godot scene is shown. Remove only those stale
# generated entries; the current AAR contributes the billrecognition entries.
if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
    $manifest = [IO.File]::ReadAllText($manifestPath)
    $cleanManifest = $manifest
    $cleanManifest = [Text.RegularExpressions.Regex]::Replace(
        $cleanManifest,
        '(?ms)\s*<activity\s+android:name="com\.appsimple\.billscan\.BillScanActivity".*?\s*/>',
        ''
    )
    $cleanManifest = [Text.RegularExpressions.Regex]::Replace(
        $cleanManifest,
        '(?ms)\s*<meta-data\s+android:name="org\.godotengine\.plugin\.v2\.BillRecognitionPlugin"\s+android:value="com\.appsimple\.billscan\.BillRecognitionPlugin"\s*/>',
        ''
    )
    if ($cleanManifest -ne $manifest) {
        if (-not $Write) {
            throw "Generated Android manifest contains stale billscan plugin entries. Re-run with -Write."
        }
        [IO.File]::WriteAllText($manifestPath, $cleanManifest, [Text.UTF8Encoding]::new($false))
        Write-Output "Removed stale billscan plugin entries from the generated Android manifest."
    }
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
		throw "Release R8 optimization is disabled. Re-run with -Write to enable it with the project keep rules."
	}
	$proguardLine = "            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'" + [Environment]::NewLine
	if ($buildContent.Contains("minifyEnabled false")) {
		$buildContent = $buildContent.Replace("minifyEnabled false", "minifyEnabled true")
		$buildContent = $buildContent.Replace("shrinkResources false", "shrinkResources true")
	} else {
		$releasePattern = '(?ms)(^\s*release\s*\{\r?\n)'
		if (-not [Text.RegularExpressions.Regex]::IsMatch($buildContent, $releasePattern)) {
			throw "Could not locate the release build type in $buildGradlePath"
		}
		$replacement = '$1' + "            minifyEnabled true" + [Environment]::NewLine + "            shrinkResources true" + [Environment]::NewLine + $proguardLine
		$buildContent = [Text.RegularExpressions.Regex]::Replace($buildContent, $releasePattern, $replacement, 1)
	}
	if (-not $buildContent.Contains("proguardFiles getDefaultProguardFile")) {
		$buildContent = [Text.RegularExpressions.Regex]::Replace(
			$buildContent,
			"(?m)^(\s*minifyEnabled true\r?\n)",
			'$1' + $proguardLine,
			1
		)
	}
	[IO.File]::WriteAllText($buildGradlePath, $buildContent, [Text.UTF8Encoding]::new($false))
	Write-Output "Enabled R8/minify in generated Android Gradle project with project keep rules."
} else {
	Write-Output "R8/minify is enabled in the generated Android Gradle project."
}

if (-not (Test-Path -LiteralPath $proguardRulesPath -PathType Leaf) -or -not ([IO.File]::ReadAllText($proguardRulesPath).Contains("Godot JNI/reflection keep rules"))) {
	if (-not $Write) {
		throw "Project-specific R8 rules are missing. Re-run with -Write."
	}
	$rules = @"
# Godot JNI/reflection keep rules.
# These symbols are loaded by the Godot runtime or plugin registry by name.
-keep class org.godotengine.godot.Godot { *; }
-keep class org.godotengine.godot.GodotLib { *; }
-keep class org.godotengine.godot.** { *; }
-keep class org.godotengine.godot.plugin.** { *; }
-keep class org.godotengine.plugin.googleplaybilling.** { *; }
-keep class com.appsimple.billrecognition.** { *; }
-keep class com.appsimple.analytics.** { *; }
-keep class com.poingstudios.godot.admob.** { *; }
-keepclassmembers,allowoptimization class * {
    @org.godotengine.godot.plugin.UsedByGodot <methods>;
}
-keepattributes *Annotation*,InnerClasses,EnclosingMethod,Signature
"@
	[IO.File]::WriteAllText($proguardRulesPath, $rules, [Text.UTF8Encoding]::new($false))
	Write-Output "Wrote project-specific R8 JNI/reflection keep rules."
}
