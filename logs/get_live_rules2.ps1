$ErrorActionPreference = 'continue'
$cfg = Get-Content "$env:USERPROFILE\.config\configstore\firebase-tools.json" -Raw | ConvertFrom-Json
$rt = $cfg.tokens.refresh_token
if (-not $rt) { Write-Output 'NO REFRESH TOKEN'; exit 1 }

# firebase-tools public OAuth client (same values embedded in firebase-tools npm package)
$cid = '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com'
$csec = 'j9iVFKfBmuQmRPdbHwmBqq4z'

$body = @{
  client_id     = $cid
  client_secret = $csec
  refresh_token = $rt
  grant_type    = 'refresh_token'
}
$resp = Invoke-RestMethod -Uri 'https://oauth2.googleapis.com/token' -Method Post -Body $body
$tok = $resp.access_token
if (-not $tok) { Write-Output 'TOKEN EXCHANGE FAILED'; exit 1 }
Write-Output ('token acquired, scopes: ' + $resp.scope)

$hdr = "Authorization: Bearer $tok"
$qhdr = 'x-goog-user-project: vkart-1'

Write-Output '=== RELEASES ==='
$rel = curl.exe -s -H $hdr -H $qhdr 'https://firebaserules.googleapis.com/v1/projects/vkart-1/releases'
$rel | Out-File -Encoding utf8 C:\vkart\logs\rules_releases.json
$rj = $rel | ConvertFrom-Json
if ($rj.error) { Write-Output ("ERROR: " + $rj.error.message); exit 1 }
foreach ($r in $rj.releases) { Write-Output ("release=" + $r.name + " ruleset=" + $r.rulesetName + " updated=" + $r.updateTime) }

$fsRelease = $rj.releases | Where-Object { $_.name -match 'cloud\.firestore' } | Select-Object -First 1
if ($fsRelease) {
  $rsId = $fsRelease.rulesetName
  Write-Output ("ruleset: " + $rsId)
  $rs = curl.exe -s -H $hdr -H $qhdr ("https://firebaserules.googleapis.com/v1/" + $rsId)
  $rs | Out-File -Encoding utf8 C:\vkart\logs\rules_live_source.json
  $source = ($rs | ConvertFrom-Json).source.files
  $i = 0
  foreach ($f in $source) {
    Write-Output ("--- file: " + $f.name + " ---")
    $out = ("C:\vkart\logs\rules_live_$i.txt" -f $i)
    $f.content | Out-File -Encoding utf8 $out
    Write-Output ($f.content.Length.ToString() + ' chars saved to ' + $out)
    $i++
  }
} else {
  Write-Output 'NO cloud.firestore release found'
}