# Function to retrive list of installed softwares on a given Windows Server
function Get-InstalledSoftware {
    <#
    .SYNOPSIS
    Retrieve the list of installed softwares on a ADSK Windows Server
    .DESCRIPTION
    This function retrieves the list of installed softwares on a Windows server by querying the non-standard WMI 
    class (Win32Reg_AddRemovePrograms). This WMI class is available only if SCCM client is installed on the Server.
    .PARAMETER ComputerName
    The name of the computer to query

    .PARAMETER Credential
    Credentials with privileges to connect to specified computer

    .INPUTS

    .NOTES

    .LINK

    .EXAMPLE
    Get-InstalledSoftware -ComputerName <ComputerName> -Credential $Credential

    
    .EXAMPLE
    Get-InstalledSoftware -ComputerName <ComputerName> -Credential $Credential

    
    .EXAMPLE
    Get-InstalledSoftware -ComputerName <ComputerName01>, <ComputerName02> -Credential $Credential
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Enter Server name to query')]
        [string[]]$ComputerName,

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    Begin {
        Write-Verbose -Message "In the begin block, setting up WMI class and Namespace to query"
        # WMI Namespace
        $cimNamespace = "Root/CIMV2"

        # WMI class
        $cimCLass = "Win32Reg_AddRemovePrograms"
    }

    Process {
        foreach ($comp in $ComputerName) {
            Write-Verbose -Message "Querying $comp's WMI for list of installed softwares"
            try {
                Write-Verbose -Message "Calling connectCIM function to return CIM session for $comp"
                $targetCIMSession = Connect-CIMSession -ComputerName $comp -Credential $Credential -ErrorAction Stop
                if ($targetCIMSession) {
                    $cimInstalledSoftwares = Get-CimInstance -CimSession $targetCIMSession -ClassName $cimCLass -Namespace $cimNamespace
                    if ($cimInstalledSoftwares) {
                        Write-Verbose -Message "Installed softwares found, building custom object"
                        $cimInstalledSoftwares | Select-Object -Property @{N = "Name"; e = { $_.DisplayName } }, InstallDate, Version, @{N = "ComputerName"; e = { $_.PSComputerName } }
                    }                    
                }
            }
            catch {
                Write-Warning -Message $_""
            }            
        }
    }

    End { }
}
Set-Alias -Name 'installedSoftware' -Value Get-InstalledSoftware