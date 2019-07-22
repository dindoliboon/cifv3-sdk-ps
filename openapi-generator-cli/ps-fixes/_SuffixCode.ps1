# Code in here will be appended to bottom of the psm1-file.

#region Initialize APIs

if ((Test-Path -Path 'Variable:\PSVersionTable') -eq $false -or ($PSVersionTable.PSVersion.Major -lt 5)) {
    throw 'Requires PowerShell 5 or greater.'
}

if ((Test-Path -Path 'Variable:\PSEdition')) {
    if ($PSEdition -eq 'Desktop')
    {
        # Ignore self-signed SSL certificate warning.
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    }    
}

$defaultBasePath = 'https://localhost'
if ($null -ne $env:CifV3ApiUri)
{
    $defaultBasePath = $env:CifV3ApiUri
}

if ((Test-Path -Path 'env:\CifV3ApiKey') -eq $false) {
    throw 'Environment variable CifV3ApiKey not defined. Set CifV3ApiKey to the token provided to you.'
}

'Creating object: Cif.V3.Management.Api.HealthApi' | Write-Verbose
$Script:HealthApi = New-Object -TypeName Cif.V3.Management.Api.HealthApi -ArgumentList @($defaultBasePath)
if ((Test-Path -Path 'Variable:\HealthApi')) {
    $Script:HealthApi.Configuration.AddApiKey('Authorization', 'Token token=' + $env:CifV3ApiKey)
} else {
    throw 'Unable to create object HealthApi.'
}

'Creating object: Cif.V3.Management.Api.HelpApi' | Write-Verbose
$Script:HelpApi = New-Object -TypeName Cif.V3.Management.Api.HelpApi -ArgumentList @($defaultBasePath)
if (-not (Test-Path -Path 'Variable:\HelpApi')) {
    throw 'Unable to create object HelpApi.'
}

'Creating object: Cif.V3.Management.Api.IndicatorsApi' | Write-Verbose
$Script:IndicatorsApi = New-Object -TypeName Cif.V3.Management.Api.IndicatorsApi -ArgumentList @($defaultBasePath)
if ((Test-Path -Path 'Variable:\IndicatorsApi')) {
    $Script:IndicatorsApi.Configuration.AddApiKey('Authorization', 'Token token=' + $env:CifV3ApiKey)
} else {
    throw 'Unable to create object IndicatorsApi.'
}

'Creating object: Cif.V3.Management.Api.TokenApi' | Write-Verbose
$Script:TokenApi = New-Object -TypeName Cif.V3.Management.Api.TokenApi -ArgumentList @($defaultBasePath)
if ((Test-Path -Path 'Variable:\TokenApi')) {
    $Script:TokenApi.Configuration.AddApiKey('Authorization', 'Token token=' + $env:CifV3ApiKey)
} else {
    throw 'Unable to create object TokenApi.'
}

#endregion
