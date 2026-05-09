$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$patterns = @("Ã", "Â", "�", "å", "æ", "è", "ã€", "ï¼", "ðŸ")
$extensions = @(".gd", ".json", ".txt", ".tscn", ".tres", ".cfg", ".md", ".gdap", ".godot", ".xml", ".java", ".properties", ".gradle", ".kts")

$selfPath = $PSCommandPath
$trackedFiles = git -C $repoRoot ls-files
$files = $trackedFiles |
	ForEach-Object { Get-Item -LiteralPath (Join-Path $repoRoot $_) -ErrorAction SilentlyContinue } |
	Where-Object {
		$path = $_.FullName
		($extensions -contains $_.Extension.ToLowerInvariant()) -and
		($path -ne $selfPath)
	}

$matches = @()
foreach ($file in $files) {
	$content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.UTF8Encoding]::new($false, $true))
	foreach ($pattern in $patterns) {
		if ($content.Contains($pattern)) {
			$matches += "$($file.FullName): contains suspicious text '$pattern'"
			break
		}
	}
}

if ($matches.Count -gt 0) {
	$matches | ForEach-Object { Write-Error $_ }
	exit 1
}

Write-Output "Text encoding check passed."
