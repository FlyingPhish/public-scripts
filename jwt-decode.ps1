Import-Module PSJWT

$credential = Get-Credential -UserName "Token" -Title "Password=JWT"
$token = $credential.GetNetworkCredential().Password
$decodedToken = ConvertFrom-JWT -Token $token

# Output key details
$decodedToken.Header
$decodedToken.Payload

# Epoch Workings
$dateTimeIssued = [System.DateTimeOffset]::FromUnixTimeSeconds($decodedToken.Payload.iat)
$dateTimeExp = [System.DateTimeOffset]::FromUnixTimeSeconds($decodedToken.Payload.exp )
$timeDifference = $dateTimeExp - $dateTimeIssued

# Convert expiry date to GMT or BST
$expiryDate = $dateTimeExp.ToUniversalTime()
if ([System.TimeZoneInfo]::Local.IsDaylightSavingTime($expiryDate.DateTime)) {
    $expiryDate = $expiryDate.ToLocalTime().ToString("dd/MM/yy HH:mm:ss") + " BST"
}
else {
    $expiryDate = $expiryDate.ToLocalTime().ToString("dd/MM/yy HH:mm:ss") + " GMT"
}

Write-Host "Time difference: $timeDifference" -ForegroundColor Green
Write-Host "Expiry date: $expiryDate" -ForegroundColor Green