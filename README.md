# Place holder for CIF 3.0 OpenAPI 2.0 YAML
YAML file to be used with AutoRest to generate a PowerShell module. Does it work? Not really.

# Requirements
- [Node.js version manager for Windows 1.1.7](https://github.com/coreybutler/nvm-windows/releases/download/1.1.7/nvm-setup.zip)
- [PowerShell Core 6.1.2](https://github.com/PowerShell/PowerShell/releases/download/v6.1.2/PowerShell-6.1.2-win-x64.msi)
- [.NET Core SDK 2.2.103](https://dotnet.microsoft.com/download/thank-you/dotnet-sdk-2.2.103-windows-x64-installer)
- [AutoRest 2.0.4300](https://github.com/Azure/autorest) - Installed with NPM
- [AutoRest incubator extensions 1.0.132](https://github.com/Azure/autorest.incubator) - Installed with AutoRest
- [Node.js 10.15.0 LTS](https://nodejs.org) - Installed with NVM

# Install
```powershell
# Install and use Node.js 10.15.0 LTS
nvm install 10.15.0
nvm use 10.15.0

# Install the AutoRest package
npm install -g autorest

# Download and extract this repo to your computer, C:\api\cifv3\
```

# Build
```powershell
# Generate and build the module
cd 'C:\api\cifv3'
autorest --debug --verbose --use=@microsoft.azure/autorest.incubator@preview --namespace=Cif.V3.Management --powershell --clear-output-folder=true --input-file="cifv3.yaml" --output-folder=".\ps"
. C:\api\cifv3\ps\build-module.ps1
```

# Usage
```powershell
# Add module to current environment
Import-Module -Name 'C:\api\cifv3\ps\CIFv3API.psd1'
$DebugPreference = 'Continue'

# See available cmdlets
(Get-Module -Name CIFv3API).ExportedCommands

# Retrieve indicators
$env:CifV3ApiKey='Token token=__YOUR_CIFV3_TOKEN__'
Invoke-IndicatorGet -Provider 'org-chn' -Limit 10
```

# To-Do
- How to change the host URL in AutoRest?
- Include all available query parameters. When all query parameters are added, the error "Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory" occurs after 45 minutes of compiling. Setting max_old_space_size did not help.
- Key/value pairs defined with additionalProperties do not work.
- Query parameters with string arrays do not work.
