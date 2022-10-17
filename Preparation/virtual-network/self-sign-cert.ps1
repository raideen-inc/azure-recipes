# Create certificates for P2S VPN
# Instruction sample from: https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site
$rootCertName = "CN=P2SRootCert"
$childCertName = "CN=P2SChildCert"

$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject $rootCertName -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
    -Subject $childCertName -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")


# Export Base64 Cert for uploading to Azure
$rootCert = get-childitem -path cert:\CurrentUser\My | Where-Object{$_.Subject -eq $rootCertName}
$content = @([System.Convert]::ToBase64String($rootCert.RawData))
$content | Out-File -FilePath .\rootcert-base64.txt -Encoding ascii

