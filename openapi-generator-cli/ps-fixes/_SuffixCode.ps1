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

if ((Test-Path -Path 'env:\CifV3ApiUri') -and (Test-Path -Path 'env:\CifV3ApiKey')) {
    Connect-CifService -ApiUri $env:CifV3ApiUri -ApiToken $env:CifV3ApiKey
}

#endregion
