#Requires -Modules @{ModuleName='InvokeBuild'; ModuleVersion='5.5.2'}

$Script:ModuleName = Get-Item -Path $BuildRoot | Select-Object -ExpandProperty Name
Get-Module -Name $ModuleName | Remove-Module -Force

$Script:apiName           = 'Cif.V3.Management'
$Script:apiVersion        = '0.1.1'
$Script:powerShellVersion = '5.0'
$Script:author            = 'Dindo Liboon'
$Script:moduleGuid        = 'f9efee84-ba4b-4114-9c5c-fa0e60106c3f'
$Script:companyName       = "North Carolina Central University"
$Script:copyright         = "(c) 2019 ${companyName}. All rights reserved."
$Script:description       = 'Provides function to interface with https://github.com/csirtgadgets/bearded-avenger/wiki'
$Script:projectUri        = 'https://github.com/dindoliboon/cifv3-sdk-ps'
$Script:licenseUri        = 'https://opensource.org/licenses/MIT'
$Script:tags              = @('cif', 'cifv3', 'stingar', 'bearded-avenger')
$Script:binRootPath       = Join-Path -Path $PSScriptRoot -ChildPath 'bin'
$Script:binChildPath      = Join-Path -Path $PSScriptRoot -ChildPath 'bin/bin'
$Script:srcChildPath      = Join-Path -Path $PSScriptRoot -ChildPath 'bin/src'
$Script:toolsChildPath    = Join-Path -Path $PSScriptRoot -ChildPath 'bin/tools'
$Script:openApiCliJar     = Join-Path -Path $toolsChildPath -ChildPath 'openapi-generator-cli.jar'
$Script:psModulePath      = Join-Path -Path $binChildPath -ChildPath "${apiName}/${apiVersion}"

task Clean {
    Write-Build Yellow "`n`n`nRemoving bin folder"

    Remove-Item -Path $binRootPath -Recurse -Force -ErrorAction SilentlyContinue
}

task IsDockerRunning {
    Write-Build Yellow "`n`n`nCheck if docker is running"

    $docker = & docker ps -a 2>&1
    if ($docker -like '* Is the docker daemon running?') {
        throw 'Ensure the Docker daemon is running correctly and you have proper permissions.'
    }
}

task BuildOpenApiGeneratorCli {
    Write-Build Yellow "`n`n`nCreating customized openapi-generator-cli"

    New-Item -Path $toolsChildPath -ItemType Directory -Force

    docker run --rm --volume ${toolsChildPath}:/mnt/tmp openapitools/openapi-generator-cli sh -c "cp /opt/openapi-generator/modules/openapi-generator-cli/target/*.jar /mnt/tmp/openapi-generator-cli.jar"

    Write-Build Yellow "`n`n`nAdds SSL ignore"
    docker run -it --rm --volume ${PSScriptRoot}:/mnt/tmp crazymax/7zip sh -c "cd /mnt/tmp/openapi-generator-cli/update-openapi-generator-cli && 7z u /mnt/tmp/bin/tools/openapi-generator-cli.jar csharp"

    Write-Build Yellow "`n`n`nAdds nullable variables and aliases"
    docker run -it --rm --volume ${PSScriptRoot}:/mnt/tmp crazymax/7zip sh -c "cd /mnt/tmp/openapi-generator-cli/update-openapi-generator-cli && 7z u /mnt/tmp/bin/tools/openapi-generator-cli.jar powershell"
}

task BuildClients {
    Write-Build Yellow "`n`n`nGenerate PowerShell and C# clients"

    docker run --rm --volume ${PSScriptRoot}:/local --volume ${openApiCliJar}:/opt/openapi-generator/modules/openapi-generator-cli/target/openapi-generator-cli.jar openapitools/openapi-generator-cli generate --generator-name powershell --input-spec /local/openapi-generator-cli/cifv3.yaml --output /local/bin/src/openapi-ps --additional-properties packageName=${apiName}
    docker run --rm --volume ${PSScriptRoot}:/local --volume ${openApiCliJar}:/opt/openapi-generator/modules/openapi-generator-cli/target/openapi-generator-cli.jar openapitools/openapi-generator-cli generate --generator-name csharp --input-spec /local/openapi-generator-cli/cifv3.yaml --output /local/bin/src/openapi-csharp --additional-properties packageName=${apiName},packageVersion=${apiVersion},targetFramework=v5.0,netCoreProjectFile=true
}

task UpgradeDotNetStandard {
    Write-Build Yellow "`n`n`nUpgrade project from .NET Standard 1.3 to 2.0"

    $projectFile = Join-Path -Path $srcChildPath -ChildPath "openapi-csharp/src/${apiName}/${apiName}.csproj"
    (Get-Content -Path $projectFile -Raw) -replace [regex]::Escape('netstandard1.3'), 'netstandard2.0' | Set-Content -Path $projectFile -Encoding utf8NoBOM

    Set-Location -Path (Split-Path -Path $projectFile -Parent)

    dotnet add package PowerShellStandard.Library -v 5.1.0
    dotnet add package FubarCoder.RestSharp.Portable.Core
    dotnet add package FubarCoder.RestSharp.Portable.HttpClient
    dotnet add package Newtonsoft.Json
    dotnet add package JsonSubTypes
    dotnet add package Microsoft.CSharp

    dotnet publish --configuration=release
}

task ApplyAliasMapping {
    Write-Build Yellow "`n`n`nAdd alias to functions"

    $psModuleSourcePath = Join-Path -Path $srcChildPath -ChildPath 'openapi-ps/src'
    $Scripts = Get-ChildItem -Path $psModuleSourcePath -File -Filter *.ps1 -Recurse | Select-Object -ExpandProperty FullName

    $map = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'openapi-generator-cli/ps-fixes/function-map.json') -Raw | ConvertFrom-Json
    foreach ($Script in $Scripts) {
        Write-Build Yellow "`n`n`nReading file ${Script}"

        $rawScript = Get-Content -Path $Script -Raw
        $map.PSObject.Properties | ForEach-Object {
            # Enable alias if function name matches
            $rawScript = $rawScript -ireplace [Regex]::Escape("#TODO#[Alias('$($_.Name)')]"), "[Alias('$($_.Value)')]"
        }

        # Clear line if alias not found in function map
        $rawScript = $rawScript -ireplace '#TODO#\[Alias\(''.+\''\)\]', ''

        $rawScript | Set-Content -Path $Script -Encoding utf8NoBOM -Force
    }
}

task BuildPsModule {
    Write-Build Yellow "`n`n`nBuilding PowerShell module"

    New-Item -Path (Join-Path -Path $psModulePath -ChildPath 'lib') -ItemType Directory -Force

    # Copy compiled binaries.
    Copy-Item -Path (Join-Path -Path $srcChildPath -ChildPath "openapi-csharp/src/${apiName}/bin/release/netstandard2.0/publish/*") -Destination (Join-Path -Path $psModulePath -ChildPath 'lib') -Recurse -Force

    # Copy user provided public PowerShell scripts.
    Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "openapi-generator-cli/ps-fixes/Public/*") -Destination (Join-Path -Path $srcChildPath -ChildPath 'openapi-ps/src/Org.OpenAPITools') -Recurse -Force

    Write-Build Yellow "`n`n`nFinding public functions and aliases"

    $SearchRecursive = $true
    $SearchRootOnly  = $false
    $PublicScriptBlock = [ScriptBlock]::Create('{0}' -f (Get-ChildItem -Path (Join-Path -Path $srcChildPath -ChildPath 'openapi-ps/src/Org.OpenAPITools') -File -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue | Get-Content -Raw | Out-String))
    $PublicFunctions = $PublicScriptBlock.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $SearchRootOnly).Name
    $PublicAlias = $PublicScriptBlock.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.ParamBlockAst] }, $SearchRecursive) | Select-Object -ExpandProperty Attributes | Where-Object { $_.TypeName.FullName -eq 'Alias' } | ForEach-Object { $_.PositionalArguments.Value }

    $ExportParam = @{}
    if ($PublicFunctions) {
        $ExportParam.Add('Function', $PublicFunctions)
    }

    if ($PublicAlias) {
        $ExportParam.Add('Alias', $PublicAlias)
    }

    Write-Build Yellow "`n`n`nCreate module manifest"

    $params = @{
        Path               = Join-Path -Path $psModulePath -ChildPath "${apiName}.psd1"
        Guid               = $moduleGuid
        Author             = $author
        CompanyName        = $companyName
        Copyright          = $copyright
        ModuleVersion      = $apiVersion
        PowerShellVersion  = $powerShellVersion
        Description        = $description
        RootModule         = "${apiName}.psm1"
        RequiredAssemblies = @("lib\${apiName}.dll",
                               'lib\FubarCoder.RestSharp.Portable.Core.dll',
                               'lib\FubarCoder.RestSharp.Portable.HttpClient.dll',
                               'lib\JsonSubTypes.dll',
                               'lib\Microsoft.CSharp.dll',
                               'lib\Newtonsoft.Json.dll')
        FunctionsToExport  = $ExportParam.Function
        CmdletsToExport    = @()
        VariablesToExport  = @()
        AliasesToExport    = $ExportParam.Alias
        ProjectUri         = $projectUri
        LicenseUri         = $licenseUri
        Tags               = $tags
    }
    New-ModuleManifest @params

    Write-Build Yellow "`n`n`nCreate module"

    $psModuleFile = Join-Path -Path $psModulePath -ChildPath "${apiName}.psm1"
    Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'openapi-generator-cli/ps-fixes/_PrefixCode.ps1') -Raw | Out-File -FilePath $psModuleFile -Encoding utf8NoBOM -Force
    $psScriptBlock = [ScriptBlock]::Create('{0}' -f (Get-ChildItem -Path (Join-Path -Path $srcChildPath -ChildPath '/openapi-ps/src') -File -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue | Get-Content -Raw | Out-String))
    $psScriptBlock | Out-File -FilePath $psModuleFile -Encoding utf8NoBOM -Append
    Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'openapi-generator-cli/ps-fixes/_SuffixCode.ps1') -Raw | Out-File -FilePath $psModuleFile -Encoding utf8NoBOM -Append

    Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath 'LICENSE') -Destination (Join-Path -Path $psModulePath -ChildPath 'LICENSE.md') -Force
}

task . Clean, IsDockerRunning, Build

task Build BuildOpenApiGeneratorCli, BuildClients, UpgradeDotNetStandard, ApplyAliasMapping, BuildPsModule
