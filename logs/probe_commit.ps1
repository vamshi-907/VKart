$ErrorActionPreference = 'continue'
$base = 'https://firestore.googleapis.com/v1/projects/vkart-1/databases/(default)/documents'
$id = 'VK-20260718-235359'

Write-Output '=== COMMIT-API ACCEPT write (SDK-style) placed -> orderReceived ==='
$c1 = curl.exe -s -X POST -o C:\vkart\logs\c_accept.json -w '%{http_code}' -H 'Content-Type: application/json' -d '@C:\vkart\logs\commit_accept.json' "$base`:commit"
Write-Output "COMMIT_ACCEPT_HTTP=$c1"
if (Test-Path C:\vkart\logs\c_accept.json) { Get-Content C:\vkart\logs\c_accept.json | Select-Object -First 10 }

$doc = curl.exe -s "$base/$id"
$js = $doc | ConvertFrom-Json
Write-Output "READBACK_STATUS=$($js.fields.status.stringValue)"

Write-Output '=== COMMIT-API revert to placed ==='
$c3 = curl.exe -s -X POST -o C:\vkart\logs\c_revert.json -w '%{http_code}' -H 'Content-Type: application/json' -d '@C:\vkart\logs\commit_revert.json' "$base`:commit"
Write-Output "COMMIT_REVERT_HTTP=$c3"
$doc2 = curl.exe -s "$base/$id"
$js2 = $doc2 | ConvertFrom-Json
Write-Output "FINAL_STATUS=$($js2.fields.status.stringValue)"
Write-Output '=== END ==='