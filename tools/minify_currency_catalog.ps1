param(
	[switch]$Write,
	[string]$CatalogPath = "godot/data/currencyinfo.json"
)

$ErrorActionPreference = "Stop"
$resolvedPath = [IO.Path]::GetFullPath($CatalogPath)
if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
	throw "Currency catalog not found: $resolvedPath"
}

$source = [IO.File]::ReadAllText($resolvedPath, [Text.UTF8Encoding]::new($false, $true))
$builder = [Text.StringBuilder]::new($source.Length)
$insideString = $false
$escaped = $false

foreach ($character in $source.ToCharArray()) {
	if ($insideString) {
		[void]$builder.Append($character)
		if ($escaped) {
			$escaped = $false
		} elseif ($character -eq [char]92) {
			$escaped = $true
		} elseif ($character -eq [char]34) {
			$insideString = $false
		}
		continue
	}

	if ($character -eq [char]34) {
		$insideString = $true
		[void]$builder.Append($character)
	} elseif ($character -notin @([char]32, [char]9, [char]10, [char]13)) {
		[void]$builder.Append($character)
	}
}

$minified = $builder.ToString()
$parsed = $minified | ConvertFrom-Json -ErrorAction Stop
if ($null -eq $parsed) {
	throw "Minified catalog could not be parsed as JSON."
}

$beforeBytes = [Text.UTF8Encoding]::new($false).GetByteCount($source)
$afterBytes = [Text.UTF8Encoding]::new($false).GetByteCount($minified)
if ($Write) {
	[IO.File]::WriteAllText($resolvedPath, $minified, [Text.UTF8Encoding]::new($false))
}

[pscustomobject]@{
	Catalog = $resolvedPath
	WriteMode = $Write.IsPresent
	BeforeMB = [math]::Round($beforeBytes / 1MB, 2)
	AfterMB = [math]::Round($afterBytes / 1MB, 2)
	SavedMB = [math]::Round(($beforeBytes - $afterBytes) / 1MB, 2)
}
