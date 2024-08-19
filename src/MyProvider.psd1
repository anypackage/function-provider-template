@{
    RootModule = 'MyProvider.psm1'
    ModuleVersion = '0.1.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = 'bc4720f6-72ad-45df-aa7d-316cb313ad5e'
    Author = 'Contoso Corporation'
    Copyright = '(c) Contoso Corporation. All rights reserved.'
    Description = 'MyProvider provider for AnyPackage.'
    PowerShellVersion = '5.1'
    RequiredModules = @('AnyPackage')
    NestedModules = @('ProviderHelpers.psm1')
    FunctionsToExport = @()
    CmdletsToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        AnyPackage = @{
            Providers = 'MyProvider'
        }
        PSData = @{
            Tags = @('AnyPackage', 'Provider')
            LicenseUri = 'https://github.com/anypackage/scoop/blob/main/LICENSE'
            ProjectUri = 'https://github.com/anypackage/scoop'
        }
    }
}