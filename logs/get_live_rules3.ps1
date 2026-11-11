$ErrorActionPreference = 'continue'
$cfg = Get-Content "$env:USERPROFILE\.config\configstore\firebase-tools.json" -Raw | ConvertFrom-Json
$tok = $cfg.tokens.access_token
$exp = $cfg.tokens.expires_at
Write-Output ("token expires_at: " + $exp)
if (-not $tok) { Write-Output 'NO STORED TOKEN'; exit 1 }

$hdr = "Authorization: Bearer $tok"
$qhdr = 'x-goog-user-project: vkart-1'

Write-Output '=== RELEASES ==='
$rel = curl.exe -s -H $hdr -H $qhdr 'https://firebaserules.googleapis.com/v1/projects/vkart-1/releases'
$rel | Out-File -Encoding utf8 C:\vkart\logs\rules_releases2.json
$rj = $rel | ConvertFrom-Json
if ($rj.error) { Write-Output ("ERROR: " + $rj.error.message) }
foreach ($r in $rj.releases) { Write-Output ("release=" + $r.name + " ruleset=" + $r.rulesetName + " updated=" + $r.updateTime) }

$fsRelease = $rj.releases | Where-Object { $_.name -match 'cloud\.firestore' } | Select-Object -First 1
if ($fsRelease) {
  $rsId = $fsRelease.rulesetName
  Write-Output ("ruleset: " + $rsId)
  $rs = curl.exe -s -H $hdr -H $qhdr ("https://firebaserules.googleapis.com/v1/" + $rsId)
  $rs | Out-File -Encoding utf8 C:\vkart\logs\rules_live_source2.json
  $source = ($rs | ConvertFrom-Json).source.files
  $i = 0
  foreach ($f in $source) {
    $out = "C:\vkart\logs\rules_live_$i.txt"
    $f.content | Out-File -Encoding utf8 $out
    Write-Output ("--- saved file " + $out + " (" + $f.content.Length + " chars) ---")
    $i++
  }
} else {
  Write-Output 'NO cloud.firestore release found'
}