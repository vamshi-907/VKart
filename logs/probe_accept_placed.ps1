$ErrorActionPreference = 'continue'
$base = 'https://firestore.googleapis.com/v1/projects/vkart-1/databases/(default)/documents/orders'
$id = 'VK-20260718-235359'
$url = "$base/$id?updateMask.fieldPaths=status&updateMask.fieldPaths=updatedAt"

Write-Output '=== STEP 1: ACCEPT write placed -> orderReceived ==='
$c1 = curl.exe -s -X PATCH -o C:\vkart\logs\p_write.json -w '%{http_code}' -H 'Content-Type: application/json' -d '@C:\vkart\logs\probe_payload_orderreceived.json' $url
Write-Output "ACCEPT_WRITE_HTTP=$c1"
if (Test-Path C:\vkart\logs\p_write.json) { Get-Content C:\vkart\logs\p_write.json | Select-Object -First 8 }

Write-Output '=== STEP 2: readback ==='
$doc = curl.exe -s "$base/$id"
$js = $doc | ConvertFrom-Json
Write-Output "READBACK_STATUS=$($js.fields.status.stringValue)"

Write-Output '=== STEP 3: revert to placed ==='
$c3 = curl.exe -s -X PATCH -o C:\vkart\logs\p_revert.json -w '%{http_code}' -H 'Content-Type: application/json' -d '@C:\vkart\logs\probe_payload_placed.json' $url
Write-Output "REVERT_WRITE_HTTP=$c3"
$doc2 = curl.exe -s "$base/$id"
$js2 = $doc2 | ConvertFrom-Json
Write-Output "FINAL_STATUS=$($js2.fields.status.stringValue)"
Write-Output '=== END ==='