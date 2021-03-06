
Given 'the module manifest exists' {
    
    $ModuleName = "PSBuildSecrets"

    $ModuleManifestPath = Join-Path "$($PSScriptRoot)\..\Source\" "$ModuleName.psd1"

    $ModuleManifestPath | Should Exist
}

Given 'the module manifest is valid' {

    $ModuleName = "PSBuildSecrets"

    $ModuleManifestPath = Join-Path "$($PSScriptRoot)\..\Source\" "$ModuleName.psd1"

    Test-ModuleManifest -Path $ModuleManifestPath | Should Be $true
}

When 'we try to import the module' {

    $ModuleName = "PSBuildSecrets"

    $ModuleManifestPath = Join-Path "$($PSScriptRoot)\..\Source\" "$ModuleName.psd1"

    {Import-Module $ModuleManifestPath }| Should Not Throw
}

Then 'the module is loaded without any exceptions' {
    
    $ModuleName = "PSBuildSecrets"

    $ModuleManifestPath = Join-Path "$($PSScriptRoot)\..\Source\" "$ModuleName.psd1"

    Get-Module -Name $ModuleName | Should Not Be $false
}


