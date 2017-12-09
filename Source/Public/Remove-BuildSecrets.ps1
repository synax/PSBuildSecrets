function Remove-BuildSecrets {
    <#
.SYNOPSIS
    Removes all variables from the specified key vault from the current environment
.PARAMETER KeyVaultName
    The name of the key vault containing the environment
.PARAMETER SubscriptionID
        Allows the user to specify a subscription id if required. if not specified, the default subscription will be used.
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [String[]]$KeyVaultName,
        [Parameter(Mandatory = $false)]
        [String]$SubscriptionID
    )

    # Check if we are logged in
    $Results = Invoke-Azcli -Arguments "account list"

    if ($Results.Count -lt 1) {
        throw "You must login first"    
    }

    # Select the appropriate subscription
    if ($SubscriptionID) {
        Invoke-Azcli -Arguments "account set -s $SubscriptionID"
    }

    $Results = Invoke-Azcli -Arguments "account show"

    if ($Results.state -ne 'Enabled') {
        throw "You must select a subscription"    
    }

    # Get all secrets from specified vault's
    $Secrets = @()
    
    foreach ($Name in $KeyVaultName) { 

        $Results = Invoke-Azcli -Arguments "keyvault show --name $Name"
        
        if ($Results.name -ne $Name) {
            throw "Key vault [$name] does not exists."
        }

        Write-Verbose "Removing Secrets from Vault [$Name]"       

        $Results = Invoke-Azcli -Arguments "keyvault secret list --vault-name $Name"

        if ($Results.Count -lt 1) {
            Write-Verbose "No secrets found in vault [$Name]"
        }

        $Results = Invoke-Azcli -Arguments "keyvault secret list --vault-name $Name"
        
        $Secrets = @()

        foreach ($Result in $Results) {
            $Secrets += Split-Path $Result.id -Leaf
        }       
        
        foreach ($Secret in $Secrets) {  
            $var = Get-Item -Path Env:$Secret -ErrorAction SilentlyContinue
            
            if ($var) {
                # Set Environment Variable
                Remove-Item -Path Env:$Secret
                Write-Verbose "Getting secret [$Secret]"
            } else {
                Write-Output "Could not find secret [$Secret] in current environment"
            }
 
        }

        # Remove vault from list of loaded vaults
        if ($Script:Vaults -contains $Name) {
            $Script:Vaults.Remove($Name)
        }
        
    
    }

}