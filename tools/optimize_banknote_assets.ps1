[CmdletBinding(SupportsShouldProcess = $true)]
param(
	[string]$CatalogPath = "godot/data/currencyinfo.json",
	[string]$ProjectRoot = "",
	[string]$OutputRoot = "exports/optimized-assets",
	[ValidateRange(1, 100)][int]$Quality = 88,
	[ValidateRange(1, 16384)][int]$MaxDimension = 2048,
	[string]$ImageMagickPath = "",
	[string[]]$AdditionalReferencePath = @(),
	[string]$ReportCsv = "",
	[string]$ReportJson = "",
	[ValidateRange(0, 100000)][int]$MaxFiles = 0,
	[switch]$Force
)

<#{
.SYNOPSIS
	Creates a safe, mirrored output set of optimized banknote images.

.DESCRIPTION
	The script reads image references from the Godot currency catalog, resolves
	them below the Godot project root, and writes optimized files to a separate
	output root. Source images are never overwritten by default.

	The output preserves the path below the Godot project root. For example,
	res://assets/bills_official/ar_10000_front.jpg becomes:
	exports/optimized-assets/assets/bills_official/ar_10000_front.jpg

	Use -AdditionalReferencePath for static runtime references such as
	godot/scripts/core/app_state.gd. This is optional because the requested
	catalog scan is based on currencyinfo.json.

.EXAMPLE
	.\tools\optimize_banknote_assets.ps1 -Quality 88 -MaxDimension 2048

.EXAMPLE
	.\tools\optimize_banknote_assets.ps1 `
		-AdditionalReferencePath godot/scripts/core/app_state.gd `
		-OutputRoot exports/optimized-assets-release `
		-Force

.NOTES
	Requires ImageMagick 7 (the magick executable). The original files remain
	untouched. PNG, JPEG, and WebP extensions are preserved so catalog routes do
	not need to change.
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Resolve-RepoPath {
	param([Parameter(Mandatory = $true)][string]$Path)

	if ([System.IO.Path]::IsPathRooted($Path)) {
		return [System.IO.Path]::GetFullPath($Path)
	}

	return [System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot $Path))
}

function Test-PathWithinRoot {
	param(
		[Parameter(Mandatory = $true)][string]$Path,
		[Parameter(Mandatory = $true)][string]$Root
	)

	$fullPath = [System.IO.Path]::GetFullPath($Path).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
	$fullRoot = [System.IO.Path]::GetFullPath($Root).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
	return $fullPath.Equals($fullRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
		$fullPath.StartsWith($fullRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-ImageMagickExecutable {
	param([string]$RequestedPath)

	if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
		$resolved = Resolve-RepoPath $RequestedPath
		if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
			throw "ImageMagick executable not found: $resolved"
		}
		return $resolved
	}

	$command = Get-Command magick -ErrorAction SilentlyContinue
	if ($null -eq $command) {
		throw "ImageMagick was not found. Install ImageMagick 7 or pass -ImageMagickPath <path-to-magick.exe>. No source files were changed."
	}

	return $command.Path
}

function Invoke-ImageMagick {
	param(
		[Parameter(Mandatory = $true)][string]$Executable,
		[Parameter(Mandatory = $true)][string[]]$Arguments
	)

	$output = (& $Executable @Arguments 2>&1 | Out-String).Trim()
	if ($LASTEXITCODE -ne 0) {
		$message = if ([string]::IsNullOrWhiteSpace($output)) { "no diagnostic output" } else { $output }
		throw "ImageMagick failed with exit code $LASTEXITCODE`: $message"
	}
}

function Get-ImageMetadata {
	param(
		[Parameter(Mandatory = $true)][string]$Executable,
		[Parameter(Mandatory = $true)][string]$Path
	)

	$identifyArguments = @(
		"identify",
		"-format",
		"%m|%w|%h",
		$Path
	)
	$raw = (& $Executable @identifyArguments 2>&1 | Out-String).Trim()
	if ($LASTEXITCODE -ne 0) {
		$message = if ([string]::IsNullOrWhiteSpace($raw)) { "no diagnostic output" } else { $raw }
		throw "ImageMagick identify failed for '$Path': $message"
	}

	$parts = $raw.Split("|", 3)
	if ($parts.Count -ne 3) {
		throw "Unexpected ImageMagick identify output for '$Path': $raw"
	}

	$file = Get-Item -LiteralPath $Path -ErrorAction Stop
	return [pscustomobject][ordered]@{
		format = $parts[0]
		width = [int]$parts[1]
		height = [int]$parts[2]
		bytes = [int64]$file.Length
	}
}

function Add-ImageReference {
	param(
		[Parameter(Mandatory = $true)][string]$Reference,
		[Parameter(Mandatory = $true)][string]$Origin
	)

	$normalized = $Reference.Trim().Replace("\\", "/")
	if ($normalized -notmatch '^res://(?<relative>.+\.(?i:png|jpe?g|webp))$') {
		return
	}

	$relativePath = $Matches.relative.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
	if (-not $script:References.ContainsKey($normalized)) {
		$script:References[$normalized] = [ordered]@{
			path = $normalized
			relative_path = $relativePath
			origins = [System.Collections.Generic.List[string]]::new()
		}
	}

	if (-not $script:References[$normalized].origins.Contains($Origin)) {
		[void]$script:References[$normalized].origins.Add($Origin)
	}
}

function Visit-JsonValue {
	param([AllowNull()][object]$Value)

	if ($null -eq $Value) {
		return
	}

	if ($Value -is [string]) {
		if ($Value -match '^res://') {
			Add-ImageReference -Reference $Value -Origin $script:CatalogPathFull
		}
		return
	}

	if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
		foreach ($item in $Value) {
			Visit-JsonValue -Value $item
		}
		return
	}

	foreach ($property in $Value.PSObject.Properties) {
		Visit-JsonValue -Value $property.Value
	}
}

function Add-TextFileReferences {
	param([Parameter(Mandatory = $true)][string]$Path)

	$text = [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false, $true))
	$matches = [regex]::Matches($text, 'res://[^"''\s<>]+\.(?i:png|jpe?g|webp)')
	foreach ($match in $matches) {
		Add-ImageReference -Reference $match.Value -Origin $Path
	}
}

function Get-RelativeOutputPath {
	param([Parameter(Mandatory = $true)][string]$RelativeProjectPath)

	return Join-Path $script:OutputRootFull $RelativeProjectPath
}

function Get-RelativePath {
	param(
		[Parameter(Mandatory = $true)][string]$BasePath,
		[Parameter(Mandatory = $true)][string]$TargetPath
	)

	$baseFull = [System.IO.Path]::GetFullPath($BasePath).TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
	$targetFull = [System.IO.Path]::GetFullPath($TargetPath)
	$baseUri = [System.Uri]::new($baseFull)
	$targetUri = [System.Uri]::new($targetFull)
	$relativeUri = $baseUri.MakeRelativeUri($targetUri)
	return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace("/", [System.IO.Path]::DirectorySeparatorChar)
}

function Get-SavedPercent {
	param(
		[Parameter(Mandatory = $true)][int64]$Before,
		[AllowNull()][Nullable[int64]]$After
	)

	if ($Before -le 0 -or $null -eq $After) {
		return $null
	}

	return [math]::Round((($Before - [int64]$After) / $Before) * 100, 2)
}

function Get-ByteSum {
	param(
		[Parameter(Mandatory = $true)][object[]]$Rows,
		[Parameter(Mandatory = $true)][string]$Property
	)

	$values = @($Rows | Where-Object { $null -ne $_.$Property } | ForEach-Object { [int64]$_.$Property })
	if ($values.Count -eq 0) {
		return [int64]0
	}

	return [int64](($values | Measure-Object -Sum).Sum)
}

$script:RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$script:CatalogPathFull = Resolve-RepoPath $CatalogPath
$script:ProjectRootFull = if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
	[System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot "godot"))
} else {
	Resolve-RepoPath $ProjectRoot
}
$script:OutputRootFull = Resolve-RepoPath $OutputRoot
$script:References = @{}

if (-not (Test-Path -LiteralPath $script:CatalogPathFull -PathType Leaf)) {
	throw "Currency catalog not found: $script:CatalogPathFull"
}
if (-not (Test-Path -LiteralPath $script:ProjectRootFull -PathType Container)) {
	throw "Godot project root not found: $script:ProjectRootFull"
}
if (Test-PathWithinRoot -Path $script:OutputRootFull -Root $script:ProjectRootFull) {
	throw "OutputRoot must be outside ProjectRoot to keep source assets safe: $script:OutputRootFull"
}

$imageMagickExecutable = Get-ImageMagickExecutable -RequestedPath $ImageMagickPath
$catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $script:CatalogPathFull | ConvertFrom-Json
Visit-JsonValue -Value $catalog

foreach ($additionalPath in $AdditionalReferencePath) {
	$additionalFull = Resolve-RepoPath $additionalPath
	if (-not (Test-Path -LiteralPath $additionalFull -PathType Leaf)) {
		throw "Additional reference file not found: $additionalFull"
	}
	Add-TextFileReferences -Path $additionalFull
}

$references = @($script:References.Values | Sort-Object -Property path)
if ($MaxFiles -gt 0 -and $references.Count -gt $MaxFiles) {
	$references = @($references | Select-Object -First $MaxFiles)
}
if ($references.Count -eq 0) {
	throw "No PNG, JPEG, or WebP references were found in $script:CatalogPathFull"
}

$isWhatIf = [bool]$WhatIfPreference
if (-not $isWhatIf) {
	[void](New-Item -ItemType Directory -Force -Path $script:OutputRootFull)
}

$rows = [System.Collections.Generic.List[object]]::new()
$startedAt = Get-Date

foreach ($reference in $references) {
	$sourceFull = [System.IO.Path]::GetFullPath((Join-Path $script:ProjectRootFull $reference.relative_path))
	$outputFull = Get-RelativeOutputPath -RelativeProjectPath $reference.relative_path
	$relativeOutput = Get-RelativePath -BasePath $script:RepoRoot -TargetPath $outputFull
	$base = [ordered]@{
		reference = $reference.path
		reference_origins = ($reference.origins -join ";")
		source_path = $sourceFull
		output_path = $outputFull
		output_relative_to_repo = $relativeOutput
		status = ""
		message = ""
		format = ""
		before_width = $null
		before_height = $null
		before_bytes = $null
		after_width = $null
		after_height = $null
		after_bytes = $null
		saved_bytes = $null
		saved_percent = $null
	}

	try {
		if (-not (Test-PathWithinRoot -Path $sourceFull -Root $script:ProjectRootFull)) {
			throw "Reference escapes ProjectRoot."
		}
		if (-not (Test-Path -LiteralPath $sourceFull -PathType Leaf)) {
			throw "Source image not found."
		}

		$before = Get-ImageMetadata -Executable $imageMagickExecutable -Path $sourceFull
		$base.format = $before.format
		$base.before_width = $before.width
		$base.before_height = $before.height
		$base.before_bytes = $before.bytes

		if ((Test-Path -LiteralPath $outputFull -PathType Leaf) -and (-not $Force)) {
			$existing = Get-ImageMetadata -Executable $imageMagickExecutable -Path $outputFull
			$base.status = "existing_not_overwritten"
			$base.message = "Output exists; pass -Force to regenerate it."
			$base.after_width = $existing.width
			$base.after_height = $existing.height
			$base.after_bytes = $existing.bytes
			$base.saved_bytes = $before.bytes - $existing.bytes
			$base.saved_percent = Get-SavedPercent -Before $before.bytes -After $existing.bytes
			[void]$rows.Add([pscustomobject]$base)
			continue
		}

		if ($isWhatIf) {
			$base.status = "planned"
			$base.message = "ImageMagick optimization planned; no output was written because -WhatIf is active."
			[void]$rows.Add([pscustomobject]$base)
			continue
		}

		$outputDirectory = Split-Path -Parent $outputFull
		[void](New-Item -ItemType Directory -Force -Path $outputDirectory)
		$extension = [System.IO.Path]::GetExtension($sourceFull).ToLowerInvariant()
		$tempPath = Join-Path $outputDirectory (".{0}.{1}{2}" -f [System.IO.Path]::GetFileNameWithoutExtension($outputFull), [guid]::NewGuid().ToString("N"), $extension)
		$resizeGeometry = "{0}x{0}>" -f $MaxDimension
		$arguments = @($sourceFull, "-auto-orient", "-strip", "-resize", $resizeGeometry)

		switch ($extension) {
			{ $_ -in @(".jpg", ".jpeg") } {
				$arguments += @("-quality", "$Quality", "-sampling-factor", "4:4:4")
			}
			".webp" {
				$arguments += @("-quality", "$Quality", "-define", "webp:method=6")
			}
			".png" {
				$arguments += @("-define", "png:compression-level=9", "-define", "png:compression-filter=5", "-define", "png:compression-strategy=1")
			}
			default {
				throw "Unsupported image extension: $extension"
			}
		}
		$arguments += $tempPath

		try {
			Invoke-ImageMagick -Executable $imageMagickExecutable -Arguments $arguments
			$optimized = Get-ImageMetadata -Executable $imageMagickExecutable -Path $tempPath
			if ($optimized.bytes -lt $before.bytes) {
				Move-Item -LiteralPath $tempPath -Destination $outputFull -Force
				$after = Get-ImageMetadata -Executable $imageMagickExecutable -Path $outputFull
				$base.status = "optimized"
				$base.message = "ImageMagick output is smaller than the source."
			} else {
				Copy-Item -LiteralPath $sourceFull -Destination $outputFull -Force
				$after = Get-ImageMetadata -Executable $imageMagickExecutable -Path $outputFull
				$base.status = "copied_source_no_gain"
				$base.message = "Optimized output was not smaller; the original bytes were copied to keep the mirror complete."
			}
			$base.after_width = $after.width
			$base.after_height = $after.height
			$base.after_bytes = $after.bytes
			$base.saved_bytes = $before.bytes - $after.bytes
			$base.saved_percent = Get-SavedPercent -Before $before.bytes -After $after.bytes
		} finally {
			if (Test-Path -LiteralPath $tempPath -PathType Leaf) {
				Remove-Item -LiteralPath $tempPath -Force
			}
		}
	} catch {
		$base.status = "error"
		$base.message = $_.Exception.Message
	}

	[void]$rows.Add([pscustomobject]$base)
}

$finishedAt = Get-Date
$reportCsvFull = if ([string]::IsNullOrWhiteSpace($ReportCsv)) {
	Join-Path $script:OutputRootFull "asset-optimization-report.csv"
} else {
	Resolve-RepoPath $ReportCsv
}
$reportJsonFull = if ([string]::IsNullOrWhiteSpace($ReportJson)) {
	Join-Path $script:OutputRootFull "asset-optimization-report.json"
} else {
	Resolve-RepoPath $ReportJson
}

if (-not $isWhatIf) {
	[void](New-Item -ItemType Directory -Force -Path (Split-Path -Parent $reportCsvFull))
	[void](New-Item -ItemType Directory -Force -Path (Split-Path -Parent $reportJsonFull))
	$rows | Export-Csv -LiteralPath $reportCsvFull -NoTypeInformation -Encoding UTF8
	$rows | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportJsonFull -Encoding UTF8
}

$optimizedRows = @($rows | Where-Object { $_.status -eq "optimized" })
$errorRows = @($rows | Where-Object { $_.status -eq "error" })
$beforeBytes = Get-ByteSum -Rows @($rows) -Property "before_bytes"
$afterBytes = Get-ByteSum -Rows @($rows) -Property "after_bytes"
$savedBytes = $beforeBytes - $afterBytes

$summary = [ordered]@{
	catalog = $script:CatalogPathFull
	project_root = $script:ProjectRootFull
	output_root = $script:OutputRootFull
	quality = $Quality
	max_dimension = $MaxDimension
	image_magick = $imageMagickExecutable
	files_selected = $references.Count
	files_optimized = $optimizedRows.Count
	files_with_errors = $errorRows.Count
	before_bytes = $beforeBytes
	after_bytes = $afterBytes
	saved_bytes = $savedBytes
	saved_percent = Get-SavedPercent -Before $beforeBytes -After $afterBytes
	report_csv = $reportCsvFull
	report_json = $reportJsonFull
	started_at = $startedAt.ToString("o")
	finished_at = $finishedAt.ToString("o")
	what_if = $isWhatIf
}

$summary | ConvertTo-Json -Depth 5
if ($errorRows.Count -gt 0) {
	Write-Error "Optimization finished with $($errorRows.Count) file error(s). See $reportJsonFull for details."
	exit 1
}
