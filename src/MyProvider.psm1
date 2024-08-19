using module AnyPackage
using namespace AnyPackage.Provider
using namespace AnyPackage.Feedback
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Threading

# Set package provider name and any optional values.
[PackageProvider('MyProvider')]
class MyProvider : PackageProvider, IGetPackage, IGetSource, ICommandNotFound {
    [PackageProviderInfo] Initialize([PackageProviderInfo] $providerInfo) {
        return Initialize-Provider -ProviderInfo $providerInfo
    }

    [void] Clean() {
        Remove-Provider
    }

    [bool] IsSource([string] $Source) {
        return Test-Source -Source $Source
    }

    [object] GetDynamicParameters([string] $commandName) {
        return Get-DynamicParameters -CommandName $commandName
    }

    [void] GetPackage([PackageRequest] $packageRequest) {
        Get-PackageImpl -PackageRequest $packageRequest
    }

    [void] GetSource([SourceRequest] $sourceRequest) {
        Get-SourceImpl -SourceRequest $sourceRequest
    }

    [IEnumerable[CommandNotFoundFeedback]] FindPackage([CommandNotFoundContext] $context, [CancellationToken] $token) {
        $feedback = Find-PackageByCommand -Context $context -Token $token -ProviderInfo $this.ProviderInfo
        $list = [List[CommandNotFoundFeedback]]::new()

        foreach ($i in $feedback) {
            $list.Add($i)
        }

        return $list
    }
}

# If Get-Package for this provider needs to expose more
# parameters then create a class per operation.
# The class is structured like the param() block but
# requires [Parameter()] attribute on each member.
# If no dynamic parameters are required remove this class
# and GetDynamicParameters method.
class GetPackageDynamicParameters {
    [Parameter()]
    [Switch]
    $DoSomething
}

# If package provider needs to store state populate this class
# with any properties and methods. Remove class if provider
# does not need to store state.
class MyProviderProviderInfo : PackageProviderInfo {
    MyProviderProviderInfo([PackageProviderInfo] $providerInfo) : base($providerInfo) { }
}

# If package provider does not expose dynamic parameters
# remove this function.
function Get-DynamicParameters {
    param([string] $CommandName)

    switch ($CommandName) {
        # Add any other commands that expose dynamic parameters
        # with appropriate class.
        'Get-Package' { [GetPackageDynamicParameters]::new() }
        default { $null }
    }
}

# Add one time initialization of provider during module import.
# If not needed remove function and Initialize method.
# If need to persist state been return an instance of MyProviderProviderInfo
# otherwise return $ProviderInfo
function Initialize-Provider {
    param ([PackageProviderInfo] $ProviderInfo)

    # Add initialization logic here

    [MyProviderProviderInfo]::new($ProviderInfo)
}

# One time clean-up logic of provider during module removal.
# If not needed remove function and Clean method.
function Remove-Provider {
    # Add clean-up logic here
}

# Tests if the source is supported by the provider.
# return $true if supported otherwise $false
# If the provider does not support sources remove
# this function and IsSource method.
function Test-Source {
    param([string] $Source)

    # Add logic to test if source is supported here
    $true
}

# Get-Package implementation
function Get-PackageImpl {
    param([PackageRequest] $PackageRequest)

    # Add getting packages logic here

    if ($PackageRequest.IsMatch('Test', '1.0')) {
        $newPackageInfoParams = @{
            Name         = 'Test'
            Version      = '1.0'
            ProviderInfo = $PackageRequest.ProviderInfo
        }
        
        $package = New-PackageInfo @newPackageInfoParams
        $PackageRequest.WritePackage($package)
    }
}

# Get-PackageSource implementation
function Get-SourceImpl {
    param([SourceRequest] $SourceRequest)

    # Add getting packages logic here

    if ($SourceRequest.IsMatch('Test')) {
        $newSourceInfoParams = @{
            Name         = 'Test'
            Location     = 'https://contoso.com/repo'
            Trusted      = $true
            ProviderInfo = $SourceRequest.ProviderInfo
        }
        
        $source = New-SourceInfo @newSourceInfoParams
        $SourceRequest.WriteSource($source)
    }
}

# Implementation function for command not found
# This feature relies on the PowerShell Feedback provider in 7.4+
# If the package provider is unable to find packages by command
# remove this function, FindPackage method with context and token parameters,
# also ICommandNotFound interface.
function Find-PackageByCommand {
    param(
        [CommandNotFoundContext]
        $Context,
        
        [CancellationToken]
        $Token,

        [PackageProviderInfo]
        $ProviderInfo
    )

    # Add finding package by command logic here

    if ($Context.Command -eq 'MyProgram') {
        #TODO: Add example with required parameters
        # https://github.com/anypackage/anypackage/issues/195
        New-Feedback -PackageName 'Package1' -ProviderInfo $ProviderInfo
        New-Feedback -PackageName 'Package2' -ProviderInfo $ProviderInfo
    }
}

# Generate new GUID for MyProvider
[guid] $id = '5b0a99c9-35d0-475c-b72a-27138acff8f8'
[PackageProviderManager]::RegisterProvider($id, [MyProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    [PackageProviderManager]::UnregisterProvider($id)
}
