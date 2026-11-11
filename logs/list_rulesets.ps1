$ErrorActionPreference = 'continue'
$tok = (Get-Content "$env:USERPROFILE\.config\configstore\firebase-tools.json" -Raw | ConvertFrom-Json).tokens.access_token
$hdr = "Authorization: Bearer $tok"
$qhdr = 'x-goog-user-project: vkart-1'

Write-Output '=== RULESETS LIST ==='
$rs = curl.exe -s -H $hdr -H $qhdr 'https://firebaserules.googleapis.com/v1/projects/vkart-1/rulesets?pageSize=10'
$rs | Out-File -Encoding utf8 C:\vkart\logs\rulesets_list.json
$rj = $rs | ConvertFrom-Json
if ($rj.error) { Write-Output ("ERROR: " + $rj.error.message); exit 1 }
foreach ($r in $rj.rulesets) { Write-Output ($r.name + ' created=' + $r.createTime + ' source_chars=' + $r.source.files[0].content.Length) }

# Fetch the SECOND-newest ruleset (the one live before today's deploy)
$sorted = $rj.rulesets | Sort-Object { [datetime]$_.createTime } -Descending
if ($sorted.Count -ge 2) {
  $prev = $sorted[1]
  Write-Output ('=== PRE-DEPLOY RULESET: ' + $prev.name + ' ===')
  $prev.source.files[0].content | Out-File -Encoding utf8 C:\vkart\logs\rules_predeploy.txt
  Write-Output ('saved rules_predeploy.txt (' + $prev.source.files[0].content.Length + ' chars)')
}