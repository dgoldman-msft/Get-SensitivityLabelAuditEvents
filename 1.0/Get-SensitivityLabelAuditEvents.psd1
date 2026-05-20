@{
    RootModule        = 'Get-SensitivityLabelAuditEvents.psm1'
    ModuleVersion     = '1.0'
    GUID              = '4a7f3b9e-c521-4d8e-b016-3f9c5d7e82a1'
    Author            = 'Dave Goldman'
    CompanyName       = ' '
    Copyright         = '(c) Dave Goldman. All rights reserved.'
    Description       = 'Retrieves Unified Audit Log entries for sensitivity label operations from Exchange Online.'
    PowerShellVersion = '7.1'

    FunctionsToExport = @('Get-SensitivityLabelAuditEvents')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('GSLAE')

    PrivateData = @{
        PSData = @{
            Tags         = @('M365', 'Purview', 'SensitivityLabel', 'AuditLog', 'ExchangeOnline', 'Compliance')
            ProjectUri   = 'https://github.com/dgoldman-msft/Get-SensitivityLabelAuditEvents'
            LicenseUri   = 'https://github.com/dgoldman-msft/Get-SensitivityLabelAuditEvents/blob/main/LICENSE'
            ReleaseNotes = '1.0 - Initial release'
        }
    }
}
