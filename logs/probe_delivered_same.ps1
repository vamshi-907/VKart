$ErrorActionPreference = 'continue'
$base = 'https://firestore.googleapis.com/v1/projects/vkart-1/databases/(default)/documents/orders'

Write-Output '=== TEST B: same-status no-op rewrite on DELIVERED order ==='
$id = 'VK-20260722-626028'
$url = "$base/$id?updateMask.fieldPaths=status&updateMask.fieldPaths=updatedAt"
$c1 = curl.exe -s -X PATCH -o C:\vkart\logs\p_bsame.json -w '%{http_code}' -H 'Content-Type: application/json' -d '@C:\vkart\logs\probe_payload_delivered.json' $url
Write-Output "SAME_STATUS_DELIVERED_HTTP=$c1"
if (Test-Path C:\vkart\logs\p_bsame.json) { Get-Content C:\vkart\logs\p_bsame.json | Select-Object -First 8 }
$doc = curl.exe -s "$base/$id"
$js = $doc | ConvertFrom-Json
Write-Output "FINAL_STATUS=$($js.fields.status.stringValue)"

Write-Output '=== END ==='