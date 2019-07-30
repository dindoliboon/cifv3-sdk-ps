function Connect-CifService {
    param (
        # URI of CIF server.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiUri,

        # API token given by owner of CIF server.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiToken
    )

    'Creating object: Cif.V3.Management.Api.HealthApi' | Write-Verbose
    $Script:HealthApi = New-Object -TypeName Cif.V3.Management.Api.HealthApi -ArgumentList @($ApiUri)
    if ((Test-Path -Path 'Variable:\HealthApi')) {
        $Script:HealthApi.Configuration.AddApiKey('Authorization', 'Token token=' + $ApiToken)
    } else {
        throw 'Unable to create object HealthApi.'
    }

    'Creating object: Cif.V3.Management.Api.HelpApi' | Write-Verbose
    $Script:HelpApi = New-Object -TypeName Cif.V3.Management.Api.HelpApi -ArgumentList @($ApiUri)
    if (-not (Test-Path -Path 'Variable:\HelpApi')) {
        throw 'Unable to create object HelpApi.'
    }

    'Creating object: Cif.V3.Management.Api.IndicatorsApi' | Write-Verbose
    $Script:IndicatorsApi = New-Object -TypeName Cif.V3.Management.Api.IndicatorsApi -ArgumentList @($ApiUri)
    if ((Test-Path -Path 'Variable:\IndicatorsApi')) {
        $Script:IndicatorsApi.Configuration.AddApiKey('Authorization', 'Token token=' + $ApiToken)
    } else {
        throw 'Unable to create object IndicatorsApi.'
    }

    'Creating object: Cif.V3.Management.Api.TokenApi' | Write-Verbose
    $Script:TokenApi = New-Object -TypeName Cif.V3.Management.Api.TokenApi -ArgumentList @($ApiUri)
    if ((Test-Path -Path 'Variable:\TokenApi')) {
        $Script:TokenApi.Configuration.AddApiKey('Authorization', 'Token token=' + $ApiToken)
    } else {
        throw 'Unable to create object TokenApi.'
    }
}
