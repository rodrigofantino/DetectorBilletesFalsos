param(
    [Parameter(Mandatory = $true)] [string] $InputPath,
    [Parameter(Mandatory = $true)] [string] $OutputPath
)

$ErrorActionPreference = 'Stop'

# Locale list copied from Google's Play Console Help page (manual store-listing translations).
$locales = @(
    'af','sq','am','ar','hy-AM','az-AZ','bn-BD','eu-ES','be','bg','my-MM','ca',
    'zh-HK','zh-CN','zh-TW','hr','cs-CZ','da-DK','nl-NL','en-AU','en-CA','en-US',
    'en-GB','en-IN','en-SG','en-ZA','et','fil','fi-FI','fr-CA','fr-FR','gl-ES',
    'ka-GE','de-DE','el-GR','gu','iw-IL','hi-IN','hu-HU','is-IS','id','it-IT',
    'ja-JP','kn-IN','kk','km-KH','ko-KR','ky-KG','lo-LA','lv','lt','mk-MK','ms-MY',
    'ms','ml-IN','mr-IN','mn-MN','ne-NP','no-NO','fa','fa-AE','fa-AF','fa-IR',
    'pl-PL','pt-BR','pt-PT','pa','ro','rm','ru-RU','sr','si-LK','sk','sl','es-419',
    'es-ES','es-US','sw','sv-SE','ta-IN','te-IN','th','tr-TR','uk','ur','vi'
)

$googleCodes = @{
    'hy-AM'='hy'; 'az-AZ'='az'; 'bn-BD'='bn'; 'eu-ES'='eu'; 'my-MM'='my';
    'zh-HK'='zh-TW'; 'zh-CN'='zh-CN'; 'zh-TW'='zh-TW'; 'cs-CZ'='cs'; 'da-DK'='da';
    'en-AU'='en'; 'en-CA'='en'; 'en-US'='en'; 'en-GB'='en'; 'en-IN'='en'; 'en-SG'='en';
    'en-ZA'='en'; 'fi-FI'='fi'; 'fr-CA'='fr'; 'fr-FR'='fr'; 'gl-ES'='gl'; 'ka-GE'='ka';
    'de-DE'='de'; 'el-GR'='el'; 'iw-IL'='he'; 'hi-IN'='hi'; 'hu-HU'='hu'; 'is-IS'='is';
    'it-IT'='it'; 'ja-JP'='ja'; 'kn-IN'='kn'; 'km-KH'='km'; 'ko-KR'='ko'; 'ky-KG'='ky';
    'lo-LA'='lo'; 'mk-MK'='mk'; 'ms-MY'='ms'; 'ml-IN'='ml'; 'mr-IN'='mr'; 'mn-MN'='mn';
    'ne-NP'='ne'; 'no-NO'='no'; 'fa-AE'='fa'; 'fa-AF'='fa'; 'fa-IR'='fa'; 'pl-PL'='pl';
    'pt-BR'='pt'; 'pt-PT'='pt'; 'rm'='de'; 'ru-RU'='ru'; 'si-LK'='si'; 'es-419'='es'; 'es-ES'='es';
    'es-US'='es'; 'sv-SE'='sv'; 'ta-IN'='ta'; 'te-IN'='te'; 'tr-TR'='tr'
}

function ConvertTo-CsvField([AllowNull()][string] $Value) {
    if ($null -eq $Value) { return '""' }
    return '"' + ($Value -replace '"', '""') + '"'
}

function Translate-Text([string] $Text, [string] $Target) {
    if ($Target -eq 'en') { return $Text }
    $encoded = [Uri]::EscapeDataString($Text)
    $uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$Target&dt=t&q=$encoded"
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            $raw = (Invoke-WebRequest -UseBasicParsing -Uri $uri -TimeoutSec 30).Content
            $json = $raw | ConvertFrom-Json
            $parts = foreach ($part in $json[0]) { $part[0] }
            if ($parts) { return ($parts -join '') }
        } catch {
            if ($attempt -eq 3) { throw }
            Start-Sleep -Milliseconds (500 * $attempt)
        }
    }
    throw "Translation returned no text for $Target"
}

$source = @(Import-Csv -LiteralPath $InputPath)
if ($source.Count -lt 1) { throw 'Input CSV has no data rows.' }
$base = $source | Where-Object { $_.language -eq 'en-US' } | Select-Object -First 1
if ($null -eq $base) { $base = $source | Select-Object -First 1 }

$rows = New-Object System.Collections.Generic.List[string]
$rows.Add('language,title,short_description,full_description')
$total = $locales.Count
$index = 0
foreach ($locale in $locales) {
    $index++
    $target = if ($googleCodes.ContainsKey($locale)) { $googleCodes[$locale] } else { ($locale -split '-')[0] }
    Write-Host "[$index/$total] Translating $locale ($target)"
    $title = Translate-Text $base.title $target
    $short = Translate-Text $base.short_description $target
    $full = Translate-Text $base.full_description $target
    $rows.Add((@($locale, $title, $short, $full) | ForEach-Object { ConvertTo-CsvField $_ }) -join ',')
    Start-Sleep -Milliseconds 100
}

$parent = Split-Path -Parent $OutputPath
if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
[System.IO.File]::WriteAllText($OutputPath, ($rows -join "`r`n") + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $($locales.Count) locales to $OutputPath"
