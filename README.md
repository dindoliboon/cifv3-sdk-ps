# CIFv3 Swagger/OpenAPI Specification

## Description

Describes CIFv3 API using Swagger/OpenAPI to generate PowerShell modules.

Provides function to interface with https://github.com/csirtgadgets/bearded-avenger/wiki

For use with PowerShell 5+.

## Installing

The easiest way to get Cif.V3.Management is using the [PowerShell Gallery](https://powershellgallery.com/packages/Cif.V3.Management/)!

This module can be loaded as-is by importing Cif.V3.Management.psd1. This is mainly intended for development purposes.

### Inspecting the module

Best practice is that you inspect modules prior to installing them. You can do this by saving the module to a local path:

``` PowerShell
PS> Save-Module -Name Cif.V3.Management -Path <path>
```

### Installing the module

Once you trust a module, you can install it using:

``` PowerShell
PS> Install-Module -Name Cif.V3.Management
```

### Updating Cif.V3.Management

Once installed from the PowerShell Gallery, you can update it using:

``` PowerShell
PS> Update-Module -Name Cif.V3.Management
```

### Uninstalling Cif.V3.Management

To uninstall Cif.V3.Management:

``` PowerShell
PS> Uninstall-Module -Name Cif.V3.Management
```

## Building from source

To speed up module load time and minimize the amount of files that needs to be signed, distributed and installed, this module contains a build script that will package up the module into the following files:

- lib/
- Cif.V3.Management.psd1
- Cif.V3.Management.psm1
- LICENSE.md

To build the module, make sure you have the following prerequisites:

- [Docker Desktop 2.0.0.3](https://www.docker.com/products/docker-desktop)
- [.NET Core SDK 2.2.103](https://dotnet.microsoft.com/download)
- [PowerShell Core 6.1.2](https://github.com/PowerShell/PowerShell)
- [Pester 4.8.1](https://www.powershellgallery.com/packages/Pester/4.8.1)
- [InvokeBuild 5.5.2](https://www.powershellgallery.com/packages/InvokeBuild/5.5.2)

Start the build by running the following command from the project root:

``` PowerShell
PS> Invoke-Build
```

This will package all code into files located in .\bin\bin\Cif.V3.Management\0.1.1. That folder is now ready to be installed, copy to any path listed in you PSModulePath environment variable and you are good to go!

## Cmdlets

| Function                             | Alias             | REST API             | Description
|--------------------------------------|-------------------|----------------------|-------------
| Invoke-TokenApiDeleteToken           | Remove-CifToken   | DELETE /tokens       | Delete a token or set of tokens
| Invoke-HelpApiGetHelp                | Get-CifHelp       | GET /                | List of REST API routes
| Invoke-IndicatorsApiGetFeed          | Get-CifFeed       | GET /feed            | Filter for a data-set, aggregate and apply respective whitelist
| Invoke-HelpApiGetHelp                | Get-CifHelp       | GET /help            | List of REST API routes
| Invoke-HelpApiGetHelpConfidence      | Get-CifConfidence | GET /help/confidence | Get a list of confidence values
| Invoke-IndicatorsApiGetIndicators    | Get-CifIndicator  | GET /indicators      | Search for a set of indicators
| Invoke-HealthApiGetPing              | Get-CifPing       | GET /ping            | Ping the router interface
| Invoke-IndicatorsApiGetSearch        | Get-CifSearch     | GET /search          | Search for an indicator
| Invoke-TokenApiGetToken              | Get-CifToken      | GET /tokens          | Search for a set of tokens
| Invoke-TokenApiUpdateToken           | Set-CifToken      | PATCH /token         | Update a token
| Invoke-IndicatorsApiCreateIndicators | New-CifIndicator  | POST /indicators     | Post indicators to the router
| Invoke-TokenApiCreateTokens          | New-CifToken      | POST /tokens         | Create a token or set of tokens
| Connect-CifService                   |                   |                      | Set API URL and API key

## Usage

```PowerShell
# Add module to current environment
Import-Module -Name Cif.V3.Management
Connect-CifService -ApiUri 'https://v3.cif.local' -ApiToken '__YOUR_CIFV3_TOKEN__'

# Get router status
Get-CifPing

# Get API routes
Get-CifHelp

# Get confidence values
Get-CifConfidence

# Create indicator
$request = New-IndicatorRequestBody -indicator 'example.com' -group 'everyone' -provider 'me@me.com' -tags @('tag1', 'tag2')
New-CifIndicator -indicatorRequestBody $request

# Retrieve indicators
(Get-CifFeed -itype fqdn).Data | Format-Table
(Get-CifIndicator).Data | Format-Table
(Get-CifSearch).Data | Format-Table

# Get tokens
(Get-CifToken).Data | Format-Table

# Create token for reading data
$request = New-TokensRequestBody -username 'testuser'
(New-CifToken -tokensRequestBody $request).Data | Format-Table

# Update existing token
$request = New-TokensUpdateBody -token '0123456789abcdef' -groups @('group1', 'group2')
Set-CifToken -tokensUpdateBody $request

# Delete a specific token
$request = New-TokensDeleteBody -token '0123456789abcdef'
Remove-CifToken -tokensDeleteBody $request

# Delete all tokens associated with user testuser
$request = New-TokensDeleteBody -username 'testuser'
Remove-CifToken -tokensDeleteBody $request
```

## To-Do

- ~~How to change the host URL?~~ Use $env:CifV3ApiUri or Connect-CifService.
- Expires does not work with Invoke-TokenApiCreateTokens, causes 503 Service Unavailable. Possible issue with bearded-avenger.

## Release history

A detailed release history is contained in the [Changelog](CHANGELOG.md).

## License

Cif.V3.Management is provided under the [MIT license](LICENSE.md).
