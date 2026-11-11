$ErrorActionPreference = 'continue'
$tok = (gcloud auth print-access-token 2>$null).Trim()
if (-not $tok) { Write-Output 'NO TOKEN'; exit 1 }
$hdr = "Authorization: Bearer $tok"

Write-Output '=== RELEASES ==='
$rel = curl.exe -s -H $hdr 'https://firebaserules.googleapis.com/v1/projects/vkart-1/releases'
$rel | Out-File -Encoding utf8 C:\vkart\logs\rules_releases.json
$rj = $rel | ConvertFrom-Json
foreach ($r in $rj.releases) { Write-Output ("release=" + $r.name + " ruleset=" + $r.rulesetName + " updated=" + $r.updateTime) }

Write-Output '=== LIVE RULESET SOURCE ==='
$fsRelease = $rj.releases | Where-Object { $_.name -match 'cloud\.firestore' } | Select-Object -First 1
if ($fsRelease) {
  $rsId = $fsRelease.rulesetName
  Write-Output ("ruleset: " + $rsId)
  $rs = curl.exe -s -H $hdr ("https://firebaserules.googleapis.com/v1/" + $rsId)
  $rs | Out-File -Encoding utf8 C:\vkart\logs\rules_live_source.json
  $source = ($rs | ConvertFrom-Json).source.files
  foreach ($f in $source) {
    Write-Output ("--- file: " + $f.name + " ---")
    $f.content | Out-File -Encoding utf8 C:\vkart\logs\rules_live firestore.rules.txt
    Write-Output ($f.content.Length.ToString() + ' chars saved to rules_live firestore.rules.txt')
  }
} else {
  Write-Output 'NO cloud.firestore release found'
}