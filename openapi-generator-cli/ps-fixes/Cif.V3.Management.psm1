#region Import functions

'API', 'Model', 'Private' | Get-ChildItem -Path {
    Join-Path $PSScriptRoot $_
} -Filter '*.ps1' | ForEach-Object {
    Write-Verbose "Importing file: $($_.BaseName)"
    try {
        . $_.FullName
    } catch {
        Write-Verbose "Can't import function!"
    }
}

#endregion


#region Initialize APIs

if ($PSEdition -eq 'Desktop')
{
    # Ignore self-signed SSL certificate warning.
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
}

'Creating object: Cif.V3.Management.Api.HealthApi' | Write-Verbose
$Script:HealthApi= New-Object -TypeName Cif.V3.Management.Api.HealthApi -ArgumentList @($null)
$Script:HealthApi.Configuration.AddApiKey('Authorization', 'Token token=' + $env:CifV3ApiKey)

'Creating object: Cif.V3.Management.Api.HelpApi' | Write-Verbose
$Script:HelpApi= New-Object -TypeName Cif.V3.Management.Api.HelpApi -ArgumentList @($null)

'Creating object: Cif.V3.Management.Api.IndicatorsApi' | Write-Verbose
$Script:IndicatorsApi= New-Object -TypeName Cif.V3.Management.Api.IndicatorsApi -ArgumentList @($null)
$Script:IndicatorsApi.Configuration.AddApiKey('Authorization', 'Token token=' + $env:CifV3ApiKey)

'Creating object: Cif.V3.Management.Api.TokenApi' | Write-Verbose
$Script:TokenApi= New-Object -TypeName Cif.V3.Management.Api.TokenApi -ArgumentList @($null)
$Script:TokenApi.Configuration.AddApiKey('Authorization', 'Token token=' + $env:CifV3ApiKey)

#endregion
