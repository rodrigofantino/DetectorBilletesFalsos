param(
	[string]$CatalogPath = "godot/data/currencyinfo.json",
	[switch]$Write
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$expectedRecordCount = 72
$expectedLegacyHash = "01b7d04931fabe6483f2434dd6bb7b78a9646d7d04ebc467e42c61e2d35b7f7b"

function Get-LegacyHash {
	param([object[]]$Entries)

	$projection = @()
	foreach ($entry in $Entries) {
		$projection += [ordered]@{
			country = $entry.country
			currency = $entry.currency
			denomination = $entry.denomination
			image_path = $entry.image_path
			summary_text = $entry.summary_text
			watermark_text = $entry.watermark_text
			security_features = $entry.security_features
			source = $entry.source
			source_url = $entry.source_url
			summary_texts_en = $entry.summary_texts.en
			watermark_texts_en = $entry.watermark_texts.en
			security_features_texts_en = $entry.security_features_texts.en
		}
	}

	$canonical = ConvertTo-Json -InputObject $projection -Depth 20 -Compress
	$bytes = [System.Text.Encoding]::UTF8.GetBytes($canonical)
	$digest = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
	return ([System.BitConverter]::ToString($digest)).Replace("-", "").ToLowerInvariant()
}

function Get-NoteId {
	param($Entry)

	$raw = "{0}_{1}" -f ([string]$Entry.currency), ([string]$Entry.denomination)
	return (($raw.ToLowerInvariant() -replace "[^a-z0-9]+", "_").Trim("_"))
}

function Assert-PropertyValue {
	param(
		$Object,
		[string]$Name,
		$Expected
	)

	if (-not ($Object.PSObject.Properties.Name -contains $Name)) {
		$Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Expected
		return $true
	}

	$actual = $Object.$Name
	$actualJson = ConvertTo-Json -InputObject $actual -Depth 10 -Compress
	$expectedJson = ConvertTo-Json -InputObject $Expected -Depth 10 -Compress
	if ($actualJson -ne $expectedJson) {
		throw "Existing '$Name' value is incompatible with the deterministic migration."
	}
	return $false
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$resolvedPath = if ([System.IO.Path]::IsPathRooted($CatalogPath)) {
	$CatalogPath
} else {
	Join-Path $repoRoot $CatalogPath
}

if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
	throw "Currency catalog not found: $resolvedPath"
}

$root = Get-Content -Raw -Encoding UTF8 -LiteralPath $resolvedPath | ConvertFrom-Json
if (-not ($root.PSObject.Properties.Name -contains "CurrencyInfo")) {
	throw "Currency catalog is missing the CurrencyInfo array."
}

$entries = @($root.CurrencyInfo)
if ($entries.Count -ne $expectedRecordCount) {
	throw "Expected $expectedRecordCount legacy records, found $($entries.Count)."
}

$beforeHash = Get-LegacyHash $entries
if ($beforeHash -ne $expectedLegacyHash) {
	throw "Legacy data fingerprint mismatch. Expected $expectedLegacyHash, found $beforeHash."
}

$changed = $false
if (-not ($root.PSObject.Properties.Name -contains "schema_version")) {
	$root | Add-Member -NotePropertyName "schema_version" -NotePropertyValue 2
	$changed = $true
} elseif ([int]$root.schema_version -ne 2) {
	throw "Unsupported existing schema_version: $($root.schema_version)"
}

$seenIds = @{}
foreach ($entry in $entries) {
	$noteId = Get-NoteId $entry
	if ($seenIds.ContainsKey($noteId)) {
		throw "Generated duplicate note_id: $noteId"
	}
	$seenIds[$noteId] = $true

	$changed = (Assert-PropertyValue $entry "note_id" $noteId) -or $changed
	$changed = (Assert-PropertyValue $entry "series" "") -or $changed

	$recognition = [ordered]@{
		front_reference = [string]$entry.image_path
		denomination_tokens = @([string]$entry.denomination)
		text_tokens = @()
	}
	$changed = (Assert-PropertyValue $entry "recognition" $recognition) -or $changed

	$review = [ordered]@{
		status = "draft"
		steps = @()
	}
	$changed = (Assert-PropertyValue $entry "review" $review) -or $changed
}

$afterHash = Get-LegacyHash $entries
if ($afterHash -ne $beforeHash) {
	throw "Migration changed one or more legacy fields."
}

if (-not $changed) {
	Write-Output "Currency catalog is already migrated to schema v2 ($($entries.Count) records)."
	exit 0
}

if (-not $Write) {
	Write-Output "Dry run passed: schema v2 metadata can be added to $($entries.Count) records without changing legacy fields."
	Write-Output "Run again with -Write to serialize the migration."
	exit 0
}

$serialized = ConvertTo-Json -InputObject $root -Depth 30
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$temporaryPath = "$resolvedPath.tmp"
[System.IO.File]::WriteAllText($temporaryPath, "$serialized`n", $utf8NoBom)

$roundTrip = Get-Content -Raw -Encoding UTF8 -LiteralPath $temporaryPath | ConvertFrom-Json
$roundTripEntries = @($roundTrip.CurrencyInfo)
if ($roundTripEntries.Count -ne $expectedRecordCount) {
	Remove-Item -LiteralPath $temporaryPath
	throw "Serialized migration changed the record count."
}
if ((Get-LegacyHash $roundTripEntries) -ne $expectedLegacyHash) {
	Remove-Item -LiteralPath $temporaryPath
	throw "Serialized migration changed legacy data."
}

Move-Item -Force -LiteralPath $temporaryPath -Destination $resolvedPath
Write-Output "Migrated currency catalog to schema v2: $($entries.Count) records, legacy hash $afterHash."
