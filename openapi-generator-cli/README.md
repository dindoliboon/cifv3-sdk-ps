# CIFv3 OpenAPI 3.0 for OpenAPI Generator
Describes CIFv3 API using OpenAPI 3.0 which can be used with OpenAPI Generator.

# Requirements
- [Docker Desktop 2.0.0.3](https://www.docker.com/products/docker-desktop)
- [.NET Core SDK 2.2.103](https://dotnet.microsoft.com/download)
- [PowerShell Core 6.1.2](https://github.com/PowerShell/PowerShell)

# Build
```powershell
# Download and extract this repo to your computer, C:\api\cifv3\

$apiRoot = 'C:\api\cifv3'
$apiName = 'Cif.V3.Management'

# Update openapi-generator-cli PowerShell template to allow nullable variables
docker run --rm --volume $apiRoot\openapi-generator-cli\update-openapi-generator-cli:/mnt/tmp openapitools/openapi-generator-cli sh -c "cp /opt/openapi-generator/modules/openapi-generator-cli/target/*.jar /mnt/tmp/bin"
docker run -it --rm --volume $apiRoot\openapi-generator-cli\update-openapi-generator-cli:/mnt/tmp crazymax/7zip sh -c "cd /mnt/tmp && 7z u bin/openapi-generator-cli.jar powershell"

# Generate PowerShell and C# clients
docker run --rm --volume $apiRoot\openapi-generator-cli:/local --volume $apiRoot\openapi-generator-cli\update-openapi-generator-cli\bin\openapi-generator-cli.jar:/opt/openapi-generator/modules/openapi-generator-cli/target/openapi-generator-cli.jar openapitools/openapi-generator-cli generate --generator-name powershell --input-spec /local/cifv3.yaml --output /local/ps --additional-properties packageName=$apiName
docker run --rm --volume $apiRoot\openapi-generator-cli:/local openapitools/openapi-generator-cli generate --generator-name csharp --input-spec /local/cifv3.yaml --output /local/ps/csharp/OpenAPIClient --additional-properties packageName=$apiName,packageVersion=0.0.3,targetFramework=v5.0,netCoreProjectFile=true

# Create Windows binary with dependencies
cd "$apiRoot\openapi-generator-cli\ps\csharp\OpenAPIClient"
dotnet publish --configuration=release --runtime win-x64

# Move default namespace files
Move-Item -Path "$apiRoot\openapi-generator-cli\ps\src\Org.OpenAPITools\*" -Destination "$apiRoot\openapi-generator-cli\ps\src\$apiName" -Force
Remove-Item -Path "$apiRoot\openapi-generator-cli\ps\src\Org.OpenAPITools" -Recurse

# Copy C# binaries for PowerShell
New-Item -Path "$apiRoot\openapi-generator-cli\ps\src\$apiName\Bin" -ItemType Directory -Force
Copy-Item -Path "$apiRoot\openapi-generator-cli\ps\csharp\OpenAPIClient\src\$apiName\bin\Release\netstandard1.3\win-x64\publish\*.dll" -Destination "$apiRoot\openapi-generator-cli\ps\src\$apiName\Bin\"

# Hide errors when using .NET Core
New-Item -Path "$apiRoot\openapi-generator-cli\ps\csharp\OpenAPIClient\bin" -ItemType Directory -Force
'@ECHO OFF' | Out-File -FilePath "$apiRoot\openapi-generator-cli\ps\csharp\OpenAPIClient\build.bat" -Encoding ascii

# Add fixes (authentication)
Copy-Item -Path "$apiRoot\openapi-generator-cli\ps-fixes\$apiName.psm1" -Destination "$apiRoot\openapi-generator-cli\ps\src\$apiName\"

# Build PowerShell module
cd "$apiRoot\openapi-generator-cli\ps"
.\Build.ps1
```

# Cmdlets
| Function                             | REST API             | Description
|--------------------------------------|----------------------|-------------
| Invoke-TokenApiDeleteToken           | DELETE /tokens       | Delete a token or set of tokens
| Invoke-HelpApiGetHelp                | GET /                | List of REST API routes
| Invoke-IndicatorsApiGetFeed          | GET /feed            | Filter for a data-set, aggregate and apply respective whitelist
| Invoke-HelpApiGetHelp                | GET /help            | List of REST API routes
| Invoke-HelpApiGetHelpConfidence      | GET /help/confidence | Get a list of confidence values
| Invoke-IndicatorsApiGetIndicators    | GET /indicators      | Search for a set of indicators
| Invoke-HealthApiGetPing              | GET /ping            | Ping the router interface
| Invoke-IndicatorsApiGetSearch        | GET /search          | Search for an indicator
| Invoke-TokenApiGetToken              | GET /tokens          | Search for a set of tokens
| Invoke-TokenApiUpdateToken           | PATCH /token         | Update a token
| Invoke-IndicatorsApiCreateIndicators | POST /indicators     | Post indicators to the router
| Invoke-TokenApiCreateTokens          | POST /tokens         | Create a token or set of tokens

# Usage
```powershell
# Add module to current environment
$env:CifV3ApiKey='__YOUR_CIFV3_TOKEN__'
Import-Module -Name 'C:\api\cifv3\openapi-generator-cli\ps\src\Cif.V3.Management'

# Get router status
Invoke-HealthApiGetPing

# Get API routes
Invoke-HelpApiGetHelp

# Get confidence values
Invoke-HelpApiGetHelpConfidence

# Create indicator
$request = New-IndicatorRequestBody -indicator 'example.com' -group 'everyone' -provider 'me@me.com' -tags @('tag1', 'tag2')
Invoke-IndicatorsApiCreateIndicators -indicatorRequestBody $request

# Retrieve indicators
(Invoke-IndicatorsApiGetFeed -itype fqdn).Data | Format-Table
(Invoke-IndicatorsApiGetIndicators).Data | Format-Table
(Invoke-IndicatorsApiGetSearch).Data | Format-Table

# Get tokens
(Invoke-TokenApiGetToken).Data | Format-Table

# Create token for reading data
$request = New-TokensRequestBody -username 'testuser'
(Invoke-TokenApiCreateTokens -tokensRequestBody $request).Data | Format-Table

# Update existing token
$request = New-TokensUpdateBody -token '0123456789abcdef' -groups @('group1', 'group2')
Invoke-TokenApiUpdateToken -tokensUpdateBody $request

# Delete a specific token
$request = New-TokensDeleteBody -token '0123456789abcdef'
Invoke-TokenApiDeleteToken -tokensDeleteBody $request

# Delete all tokens associated with user testuser
$request = New-TokensDeleteBody -username 'testuser'
Invoke-TokenApiDeleteToken -tokensDeleteBody $request
```

# To-Do
- How to change the host URL?
- Expires does not work with Invoke-TokenApiCreateTokens, causes 503 Service Unavailable. Possible issue with bearded-avenger.
