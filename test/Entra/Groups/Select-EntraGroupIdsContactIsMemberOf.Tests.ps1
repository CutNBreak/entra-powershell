# ------------------------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All Rights Reserved.  Licensed under the MIT License.  See License in the project root for license information.
# ------------------------------------------------------------------------------
BeforeAll {
    if ((Get-Module -Name Microsoft.Entra.Groups) -eq $null) {
        Import-Module Microsoft.Entra.Groups
    }
    Import-Module (Join-Path $PSScriptRoot "..\..\Common-Functions.ps1") -Force

    $scriptblock = {
        return @(
            [PSCustomObject]@{
                "Id"         = "00aa00aa-bb11-cc22-dd33-44ee44ee44ee"
                "Parameters" = $args
            }
        )
    }  
    Mock -CommandName Get-MgContactMemberOfAsGroup -MockWith $scriptblock -ModuleName Microsoft.Entra.Groups
}
  
Describe "Select-EntraGroupIdsContactIsMemberOf" {
    Context "Test for Select-EntraGroupIdsContactIsMemberOf" {
        It "Should return specific Contact Membership" {
            $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
            $Groups.GroupIds = "00aa00aa-bb11-cc22-dd33-44ee44ee44ee"
            $UserID = "11bb11bb-cc22-dd33-ee44-55ff55ff55ff"
            $result = Select-EntraGroupIdsContactIsMemberOf -OrgContactId $UserID -GroupIdsForMembershipCheck $Groups
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be '00aa00aa-bb11-cc22-dd33-44ee44ee44ee' 
            
            Should -Invoke -CommandName Get-MgContactMemberOfAsGroup -ModuleName Microsoft.Entra.Groups -Times 1
        }

        It "Should fail when OrgContactId is missing" {
            $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
            $Groups.GroupIds = "00aa00aa-bb11-cc22-dd33-44ee44ee44ee"
            { Select-EntraGroupIdsContactIsMemberOf -OrgContactId -GroupIdsForMembershipCheck $Groups } | Should -Throw "Missing an argument for parameter 'OrgContactId'*"
        }

        It "Should fail when OrgContactId is empty" {
            $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
            $Groups.GroupIds = "00aa00aa-bb11-cc22-dd33-44ee44ee44ee"
            { Select-EntraGroupIdsContactIsMemberOf -OrgContactId "" -GroupIdsForMembershipCheck $Groups } | Should -Throw "Cannot bind argument to parameter 'OrgContactId' because it is an empty string."
        }

        It "Should fail when GroupIdsForMembershipCheck is empty" {
            $UserID = "11bb11bb-cc22-dd33-ee44-55ff55ff55ff"
            { Select-EntraGroupIdsContactIsMemberOf -OrgContactId $UserID -GroupIdsForMembershipCheck } | Should -Throw "Missing an argument for parameter 'GroupIdsForMembershipCheck'*"
        }

        It "Should fail when GroupIdsForMembershipCheck is invalid" {
            $UserID = "11bb11bb-cc22-dd33-ee44-55ff55ff55ff"
            { Select-EntraGroupIdsContactIsMemberOf -OrgContactId $UserID -GroupIdsForMembershipCheck "xyz" } | Should -Throw "Cannot process argument transformation on parameter 'GroupIdsForMembershipCheck'.*"
        }

        It "Should contain 'User-Agent' header" {
            $userAgentHeaderValue = "PowerShell/$psVersion EntraPowershell/$entraVersion Select-EntraGroupIdsContactIsMemberOf"
            $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
            $Groups.GroupIds = "00aa00aa-bb11-cc22-dd33-44ee44ee44ee"
            $UserID = "11bb11bb-cc22-dd33-ee44-55ff55ff55ff"
            $result = Select-EntraGroupIdsContactIsMemberOf -OrgContactId $UserID -GroupIdsForMembershipCheck $Groups
            $result | Should -Not -BeNullOrEmpty

            $userAgentHeaderValue = "PowerShell/$psVersion EntraPowershell/$entraVersion Select-EntraGroupIdsContactIsMemberOf"

            Should -Invoke -CommandName Get-MgContactMemberOfAsGroup -ModuleName Microsoft.Entra.Groups -Times 1 -ParameterFilter {
                $Headers.'User-Agent' | Should -Be $userAgentHeaderValue
                $true
            }
        } 
        It "Should execute successfully without throwing an error" {
            # Disable confirmation prompts       
            $originalDebugPreference = $DebugPreference
            $DebugPreference = 'Continue'
            $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
            $Groups.GroupIds = "00aa00aa-bb11-cc22-dd33-44ee44ee44ee"
            $UserID = "11bb11bb-cc22-dd33-ee44-55ff55ff55ff"

            try {
                # Act & Assert: Ensure the function doesn't throw an exception
                { Select-EntraGroupIdsContactIsMemberOf -OrgContactId $UserID -GroupIdsForMembershipCheck $Groups -Debug } | Should -Not -Throw
            }
            finally {
                # Restore original confirmation preference            
                $DebugPreference = $originalDebugPreference        
            }
        }   
    }
}

