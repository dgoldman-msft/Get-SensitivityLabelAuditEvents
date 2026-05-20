# Get-SensitivityLabelAuditEvents

A PowerShell module that connects to Exchange Online and retrieves Unified Audit Log entries
for all Microsoft Purview sensitivity label operations across your Microsoft 365 tenant.

## Requirements

- PowerShell 7.1 or later
- `ExchangeOnlineManagement` module (installed automatically if not present)
- An active Exchange Online connection — the function connects automatically using `-UserPrincipalName`
- The account used must have the **Audit Logs** role in Exchange Online (typically held by
  Compliance Administrator or Security Administrator)

## Installation

Copy the `Get-SensitivityLabelAuditEvents` folder (containing the `1.0` subfolder) into one of the
directories listed in `$env:PSModulePath`, for example:

```text
C:\Users\<you>\Documents\PowerShell\Modules\Get-SensitivityLabelAuditEvents\1.0\
```

Then import it by name:

```powershell
Import-Module Get-SensitivityLabelAuditEvents
```

## Syntax

```text
Get-SensitivityLabelAuditEvents
    [-UserPrincipalName] <MailAddress>
    [-DaysBack <Int32>]
    [-ResultSize <Int32>]
    [-Operations <String>]
    [-StayConnected]
    [<CommonParameters>]
```

## Parameters

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `-UserPrincipalName` | MailAddress | Yes | — | UPN used to authenticate to Exchange Online |
| `-DaysBack` | Int32 | No | 100 | Days back from today to search (1–365) |
| `-ResultSize` | Int32 | No | 5000 | Max records per operation type (1–5000) |
| `-Operations` | String | No | All | Specific operation to query, or All for every operation |
| `-StayConnected` | Switch | No | False | Leave the Exchange Online session open after query |

### Valid values for -Operations

`All` *(default)*, `SensitivityLabelApplied`, `SensitivityLabelChanged`, `SensitivityLabelRemoved`,
`SensitivityLabelFileRead`, `SensitivityLabeledFileOpened`, `SensitivityLabeledFileModified`,
`SensitivityLabeledFileRenamed`, `SensitivityLabeledFileDeleted`, `SensitivityLabelPolicyMatched`,
`SensitivityLabelPolicyChanged`

## Examples

### 1. Query all operations for the last 100 days

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com
```

### 2. Limit to 30 days and 1000 records

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -DaysBack 30 -ResultSize 1000
```

### 3. Query a single operation type

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -Operations SensitivityLabelApplied
```

### 4. Leave the session open for follow-on commands

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -StayConnected
```

## Output

Each output object is a `PSCustomObject`. Core properties are always present; conditional
properties appear only when the underlying audit data includes the relevant field.

### Core properties

| Property | Description |
| --- | --- |
| `UserIds` | The user who performed the action |
| `UserType` | Type of user account |
| `Operations` | The audit operation name |
| `CreationDate` | Timestamp of the event |
| `ResultIndex` | Index of the result in the query page |
| `ClientIP` | IP address of the client |
| `Workload` | M365 workload (e.g. SharePoint, Exchange) |
| `Application` | Application that generated the event |
| `DeviceName` | Name of the device (endpoint events) |

### Conditional properties

| Property | Present when |
| --- | --- |
| `To`, `From`, `Subject` | `EmailInfo` is present (email workloads) |
| `Justification`, `SensitivityLabelId` | `SensitivityLabelEventData` is present (label change events) |
| `CurrentProtectionType`, `PreviousProtectionType`, `LabelId` | `Application` is populated |
| `ContentType` | `Workload` is `MipAutoLabelPublicEndpoint` |

## Get-Help

Full parameter and example documentation is available via:

```powershell
Get-Help Get-SensitivityLabelAuditEvents -Full
Get-Help Get-SensitivityLabelAuditEvents -Examples
```

## Required Permissions

### Exchange Online Role

The account running this function must have the **Audit Logs** role, which is included in:

- ✅ Compliance Administrator
- ✅ Security Administrator
- ✅ Organization Management

### Assigning the Minimum Role

To assign only the Audit Logs role in the Microsoft Purview compliance portal:

1. Go to **Permissions** > **Exchange** > **Roles**
2. Find or create a role group
3. Add the **Audit Logs** role
4. Add the user as a member

## License

© Dave Goldman. All rights reserved. See [LICENSE](LICENSE) for details.
