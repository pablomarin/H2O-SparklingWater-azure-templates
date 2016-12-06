<##############################################################################

Create AAD Service Principal.ps1

This script creates an Azure AD service principal entity in the Azure account
and assigns the Contributor role to it.

###############################################################################>

$azureAccount = Login-AzureRmAccount
cls

$appName = Read-Host "Type the AAD Application name"
$appHomePage = "https://$($appName).com"
$appIdentifierUri = "https://$($appName).com"

$existingApp = Get-AzureRmADApplication -DisplayNameStartWith $appName
if ($existingApp -ne $null)
{
    throw "Another app with the same name already exists in the Azure AAD. Try with a different name"
}

$certPassword = Read-Host "Type the certificate password:" -AsSecureString -ErrorAction Stop
$confirmPassword = Read-Host "Re-Type the certificate password:" -AsSecureString -ErrorAction Stop
$pwd1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($certPassword))
$pwd2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword))

if ($pwd1_text -ne $pwd2_text)
{
    throw "Passwords must match"
}

$certLocation = "$($env:HOMEDRIVE)$($env:HOMEPATH)\$($appName).pfx"
$cert = New-SelfSignedCertificate -CertStoreLocation "Cert:\CurrentUser\My" -Subject "CN=$($appName)" -KeySpec KeyExchange -DnsName $appHomePage
$pfx = Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$($cert.Thumbprint)" -Password $certPassword -FilePath $certLocation
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

Write-Host -ForegroundColor Green "`r`nCreating Azure AD Application..."
$app = New-AzureRmADApplication -DisplayName $appName -HomePage $appHomePage -IdentifierUris $appIdentifierUri -CertValue $keyValue -ErrorAction Stop
$sp = New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId
Write-Host -ForegroundColor Green "`r`nWaiting for Azure AD Application to be created..."
Sleep -Seconds 40
$roles = New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $app.ApplicationId.Guid

Write-Host "`r`n================================================================="

Write-Host -ForegroundColor Green "`r`nAAD Tenant Id:"
Write-host -ForegroundColor White "$($azureAccount.Context.Tenant.TenantId)"

Write-Host -ForegroundColor Green "`r`nService Principal Object Id:"
Write-Host -ForegroundColor White "$($sp.ApplicationId.Guid)"

Write-Host -ForegroundColor Green "`r`nService Principal Application Id:"
Write-Host -ForegroundColor White "$($app.ApplicationId.Guid)"

Write-Host -ForegroundColor Green "`r`nPFX certificate content:"
Write-Host -ForegroundColor White "$($keyValue)"

Write-Host -ForegroundColor Green "`r`nPFX certificate location:"
Write-host -ForegroundColor White "$($certLocation)"

#Write-Host -ForegroundColor Green "`r`nPFX certificate password:"
#Write-Host -ForegroundColor White "$($pwd1_text)"
