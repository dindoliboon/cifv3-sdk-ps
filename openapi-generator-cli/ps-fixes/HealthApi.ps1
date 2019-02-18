function Invoke-HealthApiGetPing {
    [CmdletBinding()]
    Param (
    )

    Process {
        'Calling method: HealthApi-GetPing' | Write-Verbose
        $PSBoundParameters | Out-DebugParameter | Write-Debug

        # **TODO** **NOT WORKING** ping the router interface
        # Exception calling "GetPing" with "0" argument(s): "Error calling GetPing: "
        # At ps-client\src\Cif.V3.Management\API\HealthApi.ps1:10 char:9
        # +         $Script:HealthApi.GetPing(
        # +         ~~~~~~~~~~~~~~~~~~~~~~~~~~
        # + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
        # + FullyQualifiedErrorId : ApiException
        #
        #$Script:HealthApi.GetPing(
        #)

        $params = @{
            'Method'            = 'Get'
            'Uri'               = $Script:HealthApi.Configuration.BasePath + '/ping'
            'Headers'           = @{
                'authorization' = 'Token token=' + $env:CifV3ApiKey
            }
        }

        if ($PSEdition -eq 'Core')
        {
            $params.Add('SkipCertificateCheck', $true)
        }

        Invoke-RestMethod @params
    }
}
