param(
	[string]$CatalogPath = "godot/data/currencyinfo.json",
	[ValidateSet("compat", "release")]
	[string]$Mode = "compat"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$expectedRecordCount = 334
$expectedLegacyHash = "8ddc4e8d38848acd84b7f8d51374888a840a82b64227bc57dfcbd7f266fafda6"
$supportedLocales = @("en", "es", "pt", "zh", "he", "id", "ur", "fil", "fa", "ms", "de", "ar", "fr", "tr", "hi", "bn", "ro", "nl", "ru", "sw", "th", "el", "hu", "sr", "uk", "bg", "it", "pl", "vi", "hr", "si", "my", "sv", "ps", "cs", "ko", "no", "uz", "sq", "bs", "be", "fi", "ht", "ja", "km", "lt", "lv", "sk", "ta", "te", "mr", "pa", "gu", "kn", "ml", "ne", "az", "kk", "da", "sl", "mn", "zh_hant")
$allowedMethods = @("touch", "backlight", "tilt", "visual", "uv")
$allowedSides = @("front", "back", "both")
$allowedEquipment = @("none", "white_backlight", "external_uv_lamp")
$errors = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError {
	param([string]$Message)
	$script:errors.Add($Message)
}

function Has-Property {
	param($Object, [string]$Name)
	return $null -ne $Object -and ($Object.PSObject.Properties.Name -contains $Name)
}

function Is-NonEmptyString {
	param($Value)
	return $Value -is [string] -and -not [string]::IsNullOrWhiteSpace($Value)
}

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

function Get-ExpectedNoteId {
	param($Entry)
	$raw = "{0}_{1}" -f ([string]$Entry.currency), ([string]$Entry.denomination)
	return (($raw.ToLowerInvariant() -replace "[^a-z0-9]+", "_").Trim("_"))
}

function Test-LocalizedValue {
	param(
		$Container,
		[string]$Locale,
		[string]$Context,
		[switch]$AllowArray
	)

	if (-not (Has-Property $Container $Locale)) {
		Add-ValidationError "$Context is missing locale '$Locale'."
		return
	}
	$value = $Container.$Locale
	if ($AllowArray) {
		$items = @($value)
		if ($items.Count -eq 0) {
			Add-ValidationError "$Context locale '$Locale' must contain at least one item."
			return
		}
		for ($index = 0; $index -lt $items.Count; $index++) {
			if (-not (Is-NonEmptyString $items[$index])) {
				Add-ValidationError "$Context locale '$Locale' item $index must be a non-empty string."
			} elseif ([string]$items[$index] -match "\?") {
				Add-ValidationError "$Context locale '$Locale' item $index contains a replacement question mark."
			}
		}
		return
	}
	if (-not (Is-NonEmptyString $value)) {
		Add-ValidationError "$Context locale '$Locale' must be a non-empty string."
	} elseif ([string]$value -match "\?") {
		Add-ValidationError "$Context locale '$Locale' contains a replacement question mark."
	}
}

function Test-EnglishLocalization {
	param(
		[string]$Value,
		[string]$Context
	)

	# Detect common untranslated prose, without flagging proper names such as
	# Banco de Mexico, Bank of England, Antu, or official institution names.
	$nonEnglishProse = "(?i)\b(billete|billetes|c[eé]dula|c[eé]dulas|marca de agua|marca-d['’]?agua|al trasluz|hilo de seguridad|faixa hologr[aá]fica|n[uú]mero escondido|tinta de variabilidad|relieve perceptible|fibras de seguridad|impresi[oó]n en relieve|ao inclinar)\b"
	if ($Value -match $nonEnglishProse) {
		Add-ValidationError "$Context contains untranslated Spanish or Portuguese prose."
	}
}

function Test-ResourcePath {
	param(
		[string]$ResourcePath,
		[string]$Context,
		[string]$GodotRoot
	)

	if (-not $ResourcePath.StartsWith("res://")) {
		Add-ValidationError "$Context must use a res:// path."
		return
	}
	$relativePath = $ResourcePath.Substring(6).Replace("/", [System.IO.Path]::DirectorySeparatorChar)
	$localPath = Join-Path $GodotRoot $relativePath
	if (-not (Test-Path -LiteralPath $localPath -PathType Leaf)) {
		Add-ValidationError "$Context does not exist: $ResourcePath"
	}
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$godotRoot = Join-Path $repoRoot "godot"
$resolvedPath = if ([System.IO.Path]::IsPathRooted($CatalogPath)) {
	$CatalogPath
} else {
	Join-Path $repoRoot $CatalogPath
}

if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
	Write-Error "Currency catalog not found: $resolvedPath"
	exit 1
}

try {
	$root = Get-Content -Raw -Encoding UTF8 -LiteralPath $resolvedPath | ConvertFrom-Json -ErrorAction Stop
} catch {
	Write-Error "Currency catalog is not valid JSON: $($_.Exception.Message)"
	exit 1
}

if (-not (Has-Property $root "schema_version") -or [int]$root.schema_version -ne 2) {
	Add-ValidationError "Root schema_version must be 2."
}
if (-not (Has-Property $root "CurrencyInfo")) {
	Add-ValidationError "Root CurrencyInfo array is missing."
}

$entries = if (Has-Property $root "CurrencyInfo") { @($root.CurrencyInfo) } else { @() }
if ($entries.Count -ne $expectedRecordCount) {
	Add-ValidationError "Expected $expectedRecordCount records, found $($entries.Count)."
}

if ($entries.Count -gt 0) {
	try {
		$legacyHash = Get-LegacyHash $entries
		if ($legacyHash -ne $expectedLegacyHash) {
			Add-ValidationError "Legacy fingerprint mismatch: expected $expectedLegacyHash, found $legacyHash."
		}
	} catch {
		Add-ValidationError "Could not calculate legacy fingerprint: $($_.Exception.Message)"
	}
}

$seenIds = @{}
foreach ($entry in $entries) {
	$identity = "{0}|{1}|{2}" -f $entry.country, $entry.currency, $entry.denomination
	$expectedId = Get-ExpectedNoteId $entry

	foreach ($field in @("country", "currency", "denomination", "image_path", "summary_text", "watermark_text", "source", "source_url")) {
		if (-not (Has-Property $entry $field) -or -not (Is-NonEmptyString $entry.$field)) {
			Add-ValidationError "$identity has an empty or missing '$field'."
		}
	}
	if (-not (Has-Property $entry "security_features") -or @($entry.security_features).Count -eq 0) {
		Add-ValidationError "$identity must retain at least one security feature."
	}

	if (-not (Has-Property $entry "note_id") -or $entry.note_id -ne $expectedId) {
		Add-ValidationError "$identity must use deterministic note_id '$expectedId'."
	} elseif ($seenIds.ContainsKey($entry.note_id)) {
		Add-ValidationError "Duplicate note_id '$($entry.note_id)'."
	} else {
		$seenIds[$entry.note_id] = $true
	}

	if (-not (Has-Property $entry "series") -or $entry.series -isnot [string]) {
		Add-ValidationError "$expectedId must contain a string series field."
	} elseif ($Mode -eq "release" -and [string]::IsNullOrWhiteSpace($entry.series)) {
		Add-ValidationError "$expectedId requires a curated series in release mode."
	}

	if (Has-Property $entry "image_path") {
		Test-ResourcePath ([string]$entry.image_path) "$expectedId image_path" $godotRoot
	}
	$uri = $null
	if (Has-Property $entry "source_url") {
		$validUri = [System.Uri]::TryCreate([string]$entry.source_url, [System.UriKind]::Absolute, [ref]$uri)
		if (-not $validUri -or @("http", "https") -notcontains $uri.Scheme) {
			Add-ValidationError "$expectedId source_url must be an absolute HTTP(S) URL."
		}
	}

	foreach ($localizedField in @("summary_texts", "watermark_texts", "security_features_texts")) {
		if (-not (Has-Property $entry $localizedField)) {
			Add-ValidationError "$expectedId is missing '$localizedField'."
			continue
		}
		foreach ($locale in $supportedLocales) {
			Test-LocalizedValue $entry.$localizedField $locale "$expectedId $localizedField" -AllowArray:($localizedField -eq "security_features_texts")
		}
		if ($localizedField -eq "security_features_texts") {
			$englishFeatures = @($entry.$localizedField.en)
			foreach ($locale in $supportedLocales) {
				$localizedFeatures = @($entry.$localizedField.$locale)
				if ($localizedFeatures.Count -ne $englishFeatures.Count) {
					Add-ValidationError "$expectedId $localizedField locale '$locale' must preserve the English feature count and order: expected $($englishFeatures.Count), found $($localizedFeatures.Count)."
				}
			}
			for ($index = 0; $index -lt $englishFeatures.Count; $index++) {
				Test-EnglishLocalization ([string]$englishFeatures[$index]) "$expectedId $localizedField.en item $index"
			}
		} else {
			Test-EnglishLocalization ([string]$entry.$localizedField.en) "$expectedId $localizedField.en"
		}
	}

	if (-not (Has-Property $entry "recognition")) {
		Add-ValidationError "$expectedId is missing recognition metadata."
	} else {
		$recognition = $entry.recognition
		if (-not (Has-Property $recognition "front_reference") -or $recognition.front_reference -ne $entry.image_path) {
			Add-ValidationError "$expectedId front_reference must match image_path during compatibility migration."
		} else {
			Test-ResourcePath ([string]$recognition.front_reference) "$expectedId front_reference" $godotRoot
		}
		$denominationTokens = @()
		if (Has-Property $recognition "denomination_tokens") {
			$denominationTokens = @($recognition.denomination_tokens | Where-Object { $null -ne $_ })
		}
		if ($denominationTokens -notcontains ([string]$entry.denomination)) {
			Add-ValidationError "$expectedId denomination_tokens must contain '$($entry.denomination)'."
		}
		$textTokens = @()
		if (Has-Property $recognition "text_tokens") {
			$textTokens = @($recognition.text_tokens | Where-Object { $null -ne $_ })
		}
		if ($Mode -eq "release" -and $textTokens.Count -eq 0) {
			Add-ValidationError "$expectedId requires curated OCR text_tokens in release mode."
		}
	}

	if (-not (Has-Property $entry "review")) {
		Add-ValidationError "$expectedId is missing review metadata."
		continue
	}
	$review = $entry.review
	$reviewStatus = if (Has-Property $review "status") { [string]$review.status } else { "" }
	if (@("draft", "ready") -notcontains $reviewStatus) {
		Add-ValidationError "$expectedId review status must be 'draft' or 'ready'."
	}
	$steps = @()
	if (Has-Property $review "steps") {
		$steps = @($review.steps | Where-Object { $null -ne $_ })
	}
	if ($Mode -ne "release") {
		continue
	}
	if ($reviewStatus -ne "ready") {
		Add-ValidationError "$expectedId review status must be 'ready' in release mode."
	}
	if ($steps.Count -lt 2) {
		Add-ValidationError "$expectedId requires at least two curated review steps."
	}
	$stepIds = @{}
	$hasNoEquipmentStep = $false
	foreach ($step in $steps) {
		$stepId = if (Has-Property $step "step_id") { [string]$step.step_id } else { "" }
		$stepContext = "$expectedId step '$stepId'"
		if ([string]::IsNullOrWhiteSpace($stepId)) {
			Add-ValidationError "$expectedId contains a step without step_id."
		} elseif ($stepIds.ContainsKey($stepId)) {
			Add-ValidationError "$expectedId has duplicate step_id '$stepId'."
		} else {
			$stepIds[$stepId] = $true
		}
		if (-not (Has-Property $step "method") -or $allowedMethods -notcontains $step.method) {
			Add-ValidationError "$stepContext uses an unsupported method."
		}
		if (-not (Has-Property $step "side") -or $allowedSides -notcontains $step.side) {
			Add-ValidationError "$stepContext uses an unsupported side."
		}
		if (-not (Has-Property $step "equipment") -or $allowedEquipment -notcontains $step.equipment) {
			Add-ValidationError "$stepContext uses unsupported equipment."
		} elseif ($step.equipment -eq "none") {
			$hasNoEquipmentStep = $true
		}
		if ((Has-Property $step "method") -and $step.method -eq "uv") {
			if (-not (Has-Property $step "equipment") -or $step.equipment -ne "external_uv_lamp") {
				Add-ValidationError "$stepContext UV checks require external_uv_lamp."
			}
			if (-not (Has-Property $step "optional") -or $step.optional -ne $true) {
				Add-ValidationError "$stepContext UV checks must be optional."
			}
		}
		foreach ($textField in @("title_texts", "instruction_texts", "expected_texts")) {
			if (-not (Has-Property $step $textField)) {
				Add-ValidationError "$stepContext is missing '$textField'."
				continue
			}
			foreach ($locale in $supportedLocales) {
				Test-LocalizedValue $step.$textField $locale "$stepContext $textField"
			}
		}
		if (Has-Property $step "reference_image") {
			Test-ResourcePath ([string]$step.reference_image) "$stepContext reference_image" $godotRoot
		}
		if (Has-Property $step "region") {
			$region = $step.region
			foreach ($name in @("x", "y", "width", "height")) {
				if (-not (Has-Property $region $name) -or [double]$region.$name -lt 0.0 -or [double]$region.$name -gt 1.0) {
					Add-ValidationError "$stepContext region.$name must be between 0 and 1."
				}
			}
			if ((Has-Property $region "x") -and (Has-Property $region "width") -and [double]$region.x + [double]$region.width -gt 1.0) {
				Add-ValidationError "$stepContext horizontal region exceeds image bounds."
			}
			if ((Has-Property $region "y") -and (Has-Property $region "height") -and [double]$region.y + [double]$region.height -gt 1.0) {
				Add-ValidationError "$stepContext vertical region exceeds image bounds."
			}
		}
	}
	if (-not $hasNoEquipmentStep) {
		Add-ValidationError "$expectedId requires at least one review step with no equipment."
	}
}

if ($errors.Count -gt 0) {
	$errors | ForEach-Object { Write-Error $_ }
	Write-Error "Currency catalog validation failed with $($errors.Count) error(s)."
	exit 1
}

Write-Output "Currency catalog validation passed: mode=$Mode schema=2 records=$($entries.Count) legacy_sha256=$expectedLegacyHash"
