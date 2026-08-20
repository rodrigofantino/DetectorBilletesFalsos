param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference = 'Stop'

function Fit-Text([string]$Text, [int]$Limit) {
    if ($Text.Length -le $Limit) { return $Text }
    $candidate = $Text.Substring(0, $Limit - 1)
    $space = $candidate.LastIndexOf(' ')
    if ($space -ge [Math]::Max(1, $Limit - 18)) { $candidate = $candidate.Substring(0, $space) }
    $candidate = $candidate.TrimEnd()
    if ($candidate.Length -gt ($Limit - 1)) { $candidate = $candidate.Substring(0, $Limit - 1) }
    return ($candidate + '…')
}

function Csv([AllowNull()][string]$Value) {
    if ($null -eq $Value) { return '""' }
    return '"' + ($Value -replace '"','""') + '"'
}

$rows = @(Import-Csv -LiteralPath $Path)
$out = New-Object System.Collections.Generic.List[string]
$out.Add('language,title,short_description,full_description')
foreach ($row in $rows) {
    $row.title = Fit-Text $row.title 30
    $row.short_description = Fit-Text $row.short_description 80
    $out.Add((@($row.language,$row.title,$row.short_description,$row.full_description) | ForEach-Object { Csv $_ }) -join ',')
}
[System.IO.File]::WriteAllText($Path, ($out -join "`r`n") + "`r`n", [System.Text.UTF8Encoding]::new($false))
