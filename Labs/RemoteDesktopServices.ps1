[CmdletBinding()]
param
(
    # Select platform, defaults to HyperV
    [AutomatedLab.VirtualizationHost]
    $Hypervisor = 'HyperV'
)

New-LabDefinition -Name RDS -DefaultVirtualizationEngine $Hypervisor

Add-LabDomainDefinition -Name swisskrono.com -AdminUser Install -AdminPassword Somepass1
Set-LabInstallationCredential -Username Install -Password Somepass1

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:ToolsPath'       = "$labSources\Tools"
    'Add-LabMachineDefinition:DomainName'      = 'swisskrono.com'
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2025 Datacenter (Desktop Experience)'
    'Add-LabMachineDefinition:Memory'          = 1gb
}

# Base infra: Domain and Certificate Authority
Add-LabMachineDefinition -Name RDSDC01 -Role RootDc -Domain swisskrono.com -OperatingSystem 'Windows Server 2025 Datacenter'
Add-LabMachineDefinition -Name RDSCA01 -Role CaRoot -Domain swisskrono.com -OperatingSystem 'Windows Server 2025 Datacenter'

# Gateway and Web
Add-LabMachineDefinition -Name RDSGW01 -Role RemoteDesktopGateway, RemoteDesktopWebAccess

# Connection Broker and Licensing
Add-LabMachineDefinition -Name RDSCB01 -Role RemoteDesktopConnectionBroker, RemoteDesktopLicensing

# Session Host Pool, automatically assigned to collection AutomatedLab
foreach ($count in 1..2)
{
    Add-LabMachineDefinition -Name RDSSH0$count -Roles RemoteDesktopSessionHost
}

Install-Lab
Show-LabDeploymentSummary -Detailed 

Stop-VM RDSSH01 -Passthru | Set-VM -ProcessorCount 2 -DynamicMemory -MemoryStartupBytes 2GB -Passthru | Start-VM
Stop-VM RDSSH02 -Passthru | Set-VM -ProcessorCount 2 -DynamicMemory -MemoryStartupBytes 1.5GB -Passthru | Start-VM

Invoke-LabCommand  -ComputerName RDSCB01 -ActivityName "Create SMB Share" -ScriptBlock {
    New-Item -Path 'C:\Profiles' -ItemType Directory
    New-SmbShare -Name Profiles -Path 'C:\Profiles' -FullAccess 'Everyone' 
    
}

# Create dns entry for AlwaysOn Listener
Invoke-LabCommand -ComputerName RDSDC01 -ActivityName 'Create DNS Entry for Gateway Server' -ScriptBlock {
    Add-DnsServerResourceRecordA -Name Gateway -ZoneName swisskrono.com -AllowUpdateAny -IPv4Address 192.168.11.5
} -PassThru

