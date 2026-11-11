$f = 'c:\vkart\vkart_delivery_partner\lib\screens\dashboard\partner_dashboard_screen.dart'
$c = Get-Content $f -Raw
# Only replace member accesses on `order` (the local param), not the parameter
# declaration `order: order` or the lambda `(order) =>`.
$reps = @(
  'order.customerName',
  'order\.id\b',
  'order.phoneNumber',
  'order.userId',
  'order.customerId',
  'order.grandTotal',
  'order\.status\b',
  'order.deliveryLocationEnglish',
  'order.deliveryLocationTelugu',
  'order\.deliveryLocation\b'
)
foreach ($r in $reps) {
  $c = $c -replace $r, 'widget.order.$($0 -replace "^order","")'
}
# Simpler: literal map
$c = $c -replace 'order.customerName','widget.order.customerName'
$c = $c -replace 'order\.id\b','widget.order.id'
$c = $c -replace 'order.phoneNumber','widget.order.phoneNumber'
$c = $c -replace 'order.userId','widget.order.userId'
$c = $c -replace 'order.customerId','widget.order.customerId'
$c = $c -replace 'order.grandTotal','widget.order.grandTotal'
$c = $c -replace 'order\.status\b','widget.order.status'
$c = $c -replace 'order.deliveryLocationEnglish','widget.order.deliveryLocationEnglish'
$c = $c -replace 'order.deliveryLocationTelugu','widget.order.deliveryLocationTelugu'
$c = $c -replace 'order\.deliveryLocation\b','widget.order.deliveryLocation'
Set-Content $f $c -NoNewline
Write-Output 'done'