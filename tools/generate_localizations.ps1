param(
	[string]$CatalogPath = "godot/data/currencyinfo.json",
	[string]$AppStatePath = "godot/scripts/core/app_state.gd",
	[string]$UiOutputPath = "godot/data/ui_localizations.json",
	[string[]]$Locales = @(),
	[string]$OnlyCountry = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# This generator fills only values that are currently an exact English fallback.
# It keeps the English source and existing human translations untouched. The
# public translation endpoint is intentionally called in small UTF-8 batches so
# the resulting catalog remains reproducible and reviewable by locale.

function Get-GdDictionary {
	param([string]$Source, [string]$ConstantName)
	$marker = "const $ConstantName := "
	$start = $Source.IndexOf($marker)
	if ($start -lt 0) { throw "Could not find $ConstantName in AppState." }
	$start += $marker.Length
	$depth = 0
	for ($index = $start; $index -lt $Source.Length; $index++) {
		if ($Source[$index] -eq '{') { $depth++ }
		elseif ($Source[$index] -eq '}') {
			$depth--
			if ($depth -eq 0) {
				return ($Source.Substring($start, $index - $start + 1) | ConvertFrom-Json)
			}
		}
	}
	throw "Could not read $ConstantName from AppState."
}

function ConvertTo-Hashtable {
	param($Value)
	if ($null -eq $Value) { return $null }
	if ($Value -is [string]) { return $Value }
	if ($Value -is [System.Collections.IDictionary]) {
		$map = [ordered]@{}
		foreach ($key in $Value.Keys) { $map[$key] = ConvertTo-Hashtable $Value[$key] }
		return $map
	}
	if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
		return @($Value | ForEach-Object { ConvertTo-Hashtable $_ })
	}
	if (@($Value.PSObject.Properties).Count -gt 0) {
		$map = [ordered]@{}
		foreach ($property in $Value.PSObject.Properties) { $map[$property.Name] = ConvertTo-Hashtable $property.Value }
		return $map
	}
	return $Value
}

function Get-TranslationMap {
	param([string[]]$Texts, [string]$Locale)
	$result = @{}
	$pending = @($Texts | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
	while ($pending.Count -gt 0) {
		$batch = [System.Collections.Generic.List[string]]::new()
		$length = 0
		while ($pending.Count -gt 0 -and ($length + $pending[0].Length + 1) -le 3500) {
			$value = [string]$pending[0]
			$pending = @($pending | Select-Object -Skip 1)
			$batch.Add($value)
			$length += $value.Length + 1
		}
		if ($batch.Count -eq 0) {
			$batch.Add([string]$pending[0])
			$pending = @($pending | Select-Object -Skip 1)
		}
		$source = [string]::Join("`n", $batch)
		$uri = "https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=en&tl=$Locale&dt=t&q=$([uri]::EscapeDataString($source))"
		$response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{ "User-Agent" = "Mozilla/5.0" }
		$translated = [string]$response
		$lines = @($translated -split "`r?`n")
		if ($lines.Count -ne $batch.Count) {
			throw "Translation response for '$Locale' did not preserve the batch line count."
		}
		for ($index = 0; $index -lt $batch.Count; $index++) {
			$result[$batch[$index]] = $lines[$index].Trim()
		}
	}
	return $result
}

function Add-MissingCatalogTexts {
	param($Catalog, [string]$Locale, [hashtable]$Translations, [string]$Country)
	foreach ($note in @($Catalog.CurrencyInfo | Where-Object { [string]::IsNullOrWhiteSpace($Country) -or [string]$_.country -eq $Country })) {
		foreach ($field in @("summary_texts", "watermark_texts")) {
			if ($note.$field.$Locale -eq $note.$field.en) { $note.$field.$Locale = $Translations[[string]$note.$field.en] }
		}
		for ($index = 0; $index -lt @($note.security_features_texts.en).Count; $index++) {
			if ($note.security_features_texts.$Locale[$index] -eq $note.security_features_texts.en[$index]) {
				$note.security_features_texts.$Locale[$index] = $Translations[[string]$note.security_features_texts.en[$index]]
			}
		}
		foreach ($step in @($note.review.steps)) {
			foreach ($field in @("title_texts", "instruction_texts", "expected_texts")) {
				if ($step.$field.$Locale -eq $step.$field.en) { $step.$field.$Locale = $Translations[[string]$step.$field.en] }
			}
		}
	}
}

function Repair-ContextualTranslations {
	param($Catalog)

	$replacementJson = @'
{
  "fa": { "\u0641\u0631\u0642\u0647": "\u0627\u0631\u0632\u0634 \u0627\u0633\u0645\u06cc" },
  "ur": { "\u0641\u0631\u0642\u06c1": "\u0645\u0627\u0644\u06cc\u062a" },
  "ps": { "\u0641\u0631\u0642\u0647": "\u0627\u0631\u0632\u0698\u062a" },
  "ar": { "\u0637\u0627\u0626\u0641\u0629": "\u0641\u0626\u0629" },
  "tr": { "mezhep": "kup\u00fcr" },
  "vi": { "gi\u00e1o ph\u00e1i": "m\u1ec7nh gi\u00e1" },
  "hi": { "\u0938\u0902\u092a\u094d\u0930\u0926\u093e\u092f": "\u092e\u0942\u0932\u094d\u092f\u0935\u0930\u094d\u0917" },
  "mr": { "\u0938\u0902\u092a\u094d\u0930\u0926\u093e\u092f": "\u092e\u0942\u0932\u094d\u092f\u0935\u0930\u094d\u0917" },
  "ne": { "\u0938\u0902\u092a\u094d\u0930\u0926\u093e\u092f": "\u092e\u0942\u0932\u094d\u092f\u0935\u0930\u094d\u0917" },
  "bn": { "\u09b8\u09ae\u09cd\u09aa\u09cd\u09b0\u09a6\u09be\u09af\u09bc": "\u09ae\u09c2\u09b2\u09cd\u09af\u09ae\u09be\u09a8" },
  "sw": { "madhehebu": "thamani" },
  "si": { "\u0db1\u0dd2\u0d9a\u0dcf\u0dba": "\u0dc0\u0da7\u0dd2\u0db1\u0dcf\u0d9a\u0db8" },
  "km": { "\u1793\u17b7\u1780\u17b6\u1799": "\u178f\u1798\u17d2\u179b\u17c3\u1798\u17bb\u1781" },
  "ja": { "\u5b97\u6d3e": "\u984d\u9762" },
  "ko": { "\uad50\ud30c": "\uc561\uba74" },
  "fil": { "Windowed Bank of Mauritius security thread.": "Sinulid na panseguridad ng Bank of Mauritius na may bintana." }
}
'@
	$replacements = $replacementJson | ConvertFrom-Json

	$localizedFields = @("summary_texts", "watermark_texts", "security_features_texts")
	foreach ($note in @($Catalog.CurrencyInfo)) {
		foreach ($field in $localizedFields) {
			$map = $note.$field
			foreach ($locale in $replacements.PSObject.Properties.Name) {
				if (-not ($map.PSObject.Properties.Name -contains $locale)) { continue }
				$value = $map.$locale
				if ($value -is [string]) {
					foreach ($pair in $replacements.$locale.PSObject.Properties) { $value = $value.Replace($pair.Name, [string]$pair.Value) }
					$map.$locale = $value
				} elseif ($value -is [array]) {
					for ($index = 0; $index -lt $value.Count; $index++) {
						$text = [string]$value[$index]
						foreach ($pair in $replacements.$locale.PSObject.Properties) { $text = $text.Replace($pair.Name, [string]$pair.Value) }
						$value[$index] = $text
					}
				}
			}
		}
		foreach ($step in @($note.review.steps)) {
			foreach ($field in @("title_texts", "instruction_texts", "expected_texts")) {
				$map = $step.$field
				foreach ($locale in $replacements.PSObject.Properties.Name) {
					if (-not ($map.PSObject.Properties.Name -contains $locale)) { continue }
					$value = [string]$map.$locale
					foreach ($pair in $replacements.$locale.PSObject.Properties) { $value = $value.Replace($pair.Name, [string]$pair.Value) }
					$map.$locale = $value
				}
			}
		}
	}
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$catalogFile = Join-Path $repoRoot $CatalogPath
$appStateFile = Join-Path $repoRoot $AppStatePath
$uiOutputFile = Join-Path $repoRoot $UiOutputPath
$appStateSource = Get-Content -Raw -Encoding UTF8 -LiteralPath $appStateFile
$supportedLocales = [regex]::Match($appStateSource, 'const SUPPORTED_LOCALES := \[(?<values>[^\]]+)\]').Groups['values'].Value -split ',' | ForEach-Object { $_.Trim().Trim('"') }
$catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogFile | ConvertFrom-Json
$uiTexts = Get-GdDictionary $appStateSource "UI_TEXTS"
$countryLabels = Get-GdDictionary $appStateSource "COUNTRY_LABELS"
$currencyLabels = Get-GdDictionary $appStateSource "CURRENCY_LABELS"
$aboutSummaries = Get-GdDictionary $appStateSource "ABOUT_UPDATE_SUMMARY"
$uiTranslations = if (Test-Path -LiteralPath $uiOutputFile -PathType Leaf) {
	ConvertTo-Hashtable (Get-Content -Raw -Encoding UTF8 -LiteralPath $uiOutputFile | ConvertFrom-Json)
} else {
	[ordered]@{ schema_version = 1; ui_texts = @{}; country_labels = @{}; currency_labels = @{}; about_update_summary = @{} }
}

$targetLocales = $supportedLocales | Where-Object { $_ -ne "en" -and ($Locales.Count -eq 0 -or $Locales -contains $_) }
foreach ($locale in $targetLocales) {
	$catalogValues = [System.Collections.Generic.List[string]]::new()
	foreach ($note in @($catalog.CurrencyInfo | Where-Object { [string]::IsNullOrWhiteSpace($OnlyCountry) -or [string]$_.country -eq $OnlyCountry })) {
		foreach ($field in @("summary_texts", "watermark_texts")) { if ($note.$field.$locale -eq $note.$field.en) { $catalogValues.Add([string]$note.$field.en) } }
		for ($index = 0; $index -lt @($note.security_features_texts.en).Count; $index++) { if ($note.security_features_texts.$locale[$index] -eq $note.security_features_texts.en[$index]) { $catalogValues.Add([string]$note.security_features_texts.en[$index]) } }
		foreach ($step in @($note.review.steps)) { foreach ($field in @("title_texts", "instruction_texts", "expected_texts")) { if ($step.$field.$locale -eq $step.$field.en) { $catalogValues.Add([string]$step.$field.en) } } }
	}
	$uiValues = [System.Collections.Generic.List[string]]::new()
	foreach ($section in @($uiTexts, $countryLabels, $currencyLabels)) {
		foreach ($key in $section.en.PSObject.Properties.Name) {
			if (-not ($section.PSObject.Properties.Name -contains $locale) -or -not ($section.$locale.PSObject.Properties.Name -contains $key) -or $section.$locale.$key -eq $section.en.$key) { $uiValues.Add([string]$section.en.$key) }
		}
	}
	if (-not ($aboutSummaries.PSObject.Properties.Name -contains $locale) -or $aboutSummaries.$locale -eq $aboutSummaries.en) { $uiValues.Add([string]$aboutSummaries.en) }
	Write-Host "Translating $locale ($($catalogValues.Count) catalog values, $($uiValues.Count) UI values)..."
	$translations = Get-TranslationMap @($catalogValues + $uiValues) $locale
	Add-MissingCatalogTexts $catalog $locale $translations $OnlyCountry
	foreach ($pair in @{ ui_texts = $uiTexts; country_labels = $countryLabels; currency_labels = $currencyLabels }.GetEnumerator()) {
		$values = [ordered]@{}
		foreach ($key in $pair.Value.en.PSObject.Properties.Name) {
			$existing = if (($pair.Value.PSObject.Properties.Name -contains $locale) -and ($pair.Value.$locale.PSObject.Properties.Name -contains $key)) { [string]$pair.Value.$locale.$key } else { "" }
			$values[$key] = if ($existing -and $existing -ne [string]$pair.Value.en.$key) { $existing } else { $translations[[string]$pair.Value.en.$key] }
		}
		$uiTranslations[$pair.Key][$locale] = $values
	}
	$existingAbout = if ($aboutSummaries.PSObject.Properties.Name -contains $locale) { [string]$aboutSummaries.$locale } else { "" }
	$uiTranslations.about_update_summary[$locale] = if ($existingAbout -and $existingAbout -ne [string]$aboutSummaries.en) { $existingAbout } else { $translations[[string]$aboutSummaries.en] }
}

Repair-ContextualTranslations $catalog

$catalog | ConvertTo-Json -Depth 100 | Set-Content -Encoding UTF8 -LiteralPath $catalogFile
$uiTranslations | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 -LiteralPath $uiOutputFile
Write-Host "Localization generation complete."
