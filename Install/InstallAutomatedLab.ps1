Install-PSResource -Name Pester -TrustRepository -Scope AllUsers
Install-PSResource -Name AutomatedLab -NoClobber -TrustRepository -Scope AllUsers

# Pre-configure telemetry
[Environment]::SetEnvironmentVariable('AUTOMATEDLAB_TELEMETRY_OPTIN', 'false', 'Machine')
$env:AUTOMATEDLAB_TELEMETRY_OPTIN = 'false'

# Pre-configure Lab Host Remoting
Enable-LabHostRemoting -Force

# Windows
New-LabSourcesFolder -DriveLetter C

# Set Some Settings
Set-PSFConfig -Module AutomatedLab -Name LabAppDataRoot -Value "C:\AutomatedLab" -PassThru | Register-PSFConfig
Set-PSFConfig -Module AutomatedLab -Name DiskDeploymentInProgressPath -Value 'C:\AutomatedLab\LabDiskDeploymentInProgress.txt' -PassThru | Register-PSFConfig
Set-PSFConfig -Module AutomatedLab -Name ProductKeyFilePath -Value 'C:\AutomatedLab\Assets\ProductKeys.xml' -PassThru | Register-PSFConfig
Set-PSFConfig -Module AutomatedLab -Name ProductKeyFilePathCustom -Value 'C:\AutomatedLab\Assets\ProductKeysCustom.xml' -PassThru | Register-PSFConfig
Set-PSFConfig -Module AutomatedLab -Name SwitchDeploymentInProgressPath -Value 'C:\AutomatedLab\VSwitchDeploymentInProgress.txt' -PassThru | Register-PSFConfig
Set-PSFConfig -Module AutomatedLab -Name VmPath -Value 'C:\AutomatedLab-Vms' -PassThru | Register-PSFConfig
