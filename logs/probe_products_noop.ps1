$ErrorActionPreference = 'continue'
$base = 'https://firestore.googleapis.com/v1/projects/vkart-1/databases/(default)/documents'

Write-Output '=== GET one product ==='
$list = curl.exe -s "$base/products?pageSize=1"
$list | Out-File -Encoding utf8 C:\vkart\logs\probe_products_list.json
$lj = $list | ConvertFrom-Json
if ($lj.error) { Write-Output ("LIST ERROR: " + $lj.error.message); exit 1 }
if (-not $lj.documents) { Write-Output 'NO PRODUCTS'; exit 1 }
$doc = $lj.documents[0]
$docName = $doc.name
Write-Output ("doc: " + $docName)

# Build a no-op PATCH: pick one simple string field and write its current value back.
$field = $null; $val = $null
foreach ($k in @('name','title','productName','productNameEnglish')) {
  if ($doc.fields.PSObject.Properties.Name -contains $k) { $field = $k; $val = $doc.fields.$k.stringValue; break }
}
if (-not $field) { Write-Output 'NO STRING FIELD FOUND'; $doc.fields.PSObject.Properties.Name -join ', '; exit 1 }
Write-Output ("no-op field: " + $field + " = " + $val)

$payload = @{ fields = @{ } } | ConvertTo-Json -Depth 5
# build payload manually to control value type
$payload = '{"fields":{"' + $field + '":{"stringValue":"' + ($val -replace '"','\"') + '"}}}'
$payload | Out-File -Encoding ascii C:\vkart\logs\probe_payload_noop.json

$enc = [uri]::EscapeDataString($field)
$urlInline = "https://firestore.googleapis.com/v1/projects/vkart-1/databases/(default)/documents/products/1?updateMask.fieldPaths=$enc"
Write-Output ("URL: " + $urlInline)
$c = curl.exe -s -X PATCH -o C:\vkart\logs\p_noop.json -w '%{http_code}' -H 'Content-Type: application/json' -d '@C:\vkart\logs\probe_payload_noop.json' "$urlInline"
Write-Output ("PRODUCT_NOOP_HTTP=" + $c)
if (Test-Path C:\vkart\logs\p_noop.json) { Get-Content C:\vkart\logs\p_noop.json | Select-Object -First 6 }
Write-Output '=== END ==='