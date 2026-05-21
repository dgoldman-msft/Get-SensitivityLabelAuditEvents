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

The function is also available via the alias **`GSLAE`** once the module is imported.

## Syntax

```text
Get-SensitivityLabelAuditEvents
    [-UserPrincipalName] <MailAddress>
    [-DaysBack <Int32>]
    [-ResultSize <Int32>]
    [-Operations <String>]
    [-StayConnected]
    [-AllData]
    [-ExportToCsv]
    [-LogDirectory <String>]
    [<CommonParameters>]
```

## Parameters

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `-UserPrincipalName` | MailAddress | Yes | — | UPN used to authenticate to Exchange Online |
| `-DaysBack` | Int32 | No | 100 | Days back from today to search (1–365) |
| `-ResultSize` | Int32 | No | 5000 | Max records per operation type (1–5000) |
| `-Operations` | String | No | `All` | Specific operation to query, or `All` for every operation |
| `-StayConnected` | Switch | No | `$false` | Leave the Exchange Online session open after the query |
| `-AllData` | Switch | No | `$false` | Show all properties on the console; also enables per-operation count/not-found messages |
| `-ExportToCsv` | Switch | No | `$false` | Export all collected records to a timestamped CSV file in `-LogDirectory` |
| `-LogDirectory` | String | No | `$env:TEMP\Get-SensitivityLabelAuditEvents` | Directory for timestamped log files (created automatically if absent) |
| `-FilterDeviceName` | String | No | — | After querying, keep only records whose `DeviceName` matches this value. Supports wildcards (e.g. `WIN*`). Case-insensitive. |
| `-FilterWorkload` | String | No | — | After querying, keep only records whose `Workload` matches this value. Supports wildcards (e.g. `SharePoint*`). Case-insensitive. |

### Valid values for -Operations

| Group | Operations |
| --- | --- |
| *(default)* | `All` |
| File / item — Microsoft 365 apps | `SensitivityLabelApplied`, `SensitivityLabelUpdated`, `SensitivityLabelRemoved` |
| File / item — Office for the web, SharePoint details pane, Teams Files tab, auto-labeling | `FileSensitivityLabelApplied`, `FileSensitivityLabelChanged`, `FileSensitivityLabelRemoved` |
| Failure operations | `FileSensitivityLabelAppliedFailed`, `FileSensitivityLabelChangedFailed`, `FileSensitivityLabelRemovedFailed` |
| Site / container (SharePoint sites, Teams sites, Loop workspaces) | `SiteSensitivityLabelApplied`, `SiteSensitivityLabelChanged`, `SiteSensitivityLabelRemoved` |
| Legacy / additional | `SensitivityLabelFileRead`, `SensitivityLabeledFileOpened`, `SensitivityLabeledFileModified`, `SensitivityLabeledFileRenamed`, `SensitivityLabeledFileDeleted`, `SensitivityLabelPolicyMatched`, `SensitivityLabelPolicyChanged` |

> **Note:** `SensitivityLabelRemoved` covers label removals performed in Microsoft 365 desktop apps
> (Word, Excel, PowerPoint, Outlook). Label removals performed via Office for the web, SharePoint,
> or Teams are logged under `FileSensitivityLabelRemoved` instead.

## Examples

### 1. Query all operations for the last 100 days

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com
```

### 2. Limit to 30 days and 1000 records per operation

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

### 5. Show all properties for each record on the console

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -AllData
```

### 6. Export results to a CSV file

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -ExportToCsv
```

### 7. Write logs to a custom directory

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -LogDirectory "C:\Reports\AuditLogs"
```

### 8. Use the GSLAE alias

```powershell
GSLAE -UserPrincipalName admin@contoso.com
```

### 9. Filter results to a specific device

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -FilterDeviceName 'WIN*'
```

### 10. Filter results to a specific workload

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -FilterWorkload 'PublicEndpoint'
```

### 11. Combine filters — device and workload together

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -FilterDeviceName '*WIN11*' -FilterWorkload 'PublicEndpoint' -ExportToCsv
```

## Output

Each output object is a `PSCustomObject`. Core properties are always present; conditional
properties appear only when the underlying audit data includes the relevant field.

### Core properties

| Property | Description |
| --- | --- |
| `UserIds` | The user who performed the action |
| `UserType` | Type of user account (e.g. Regular, Admin) |
| `Operations` | The audit operation name |
| `CreationDate` | Timestamp of the event |
| `ResultIndex` | Index of the result within the query page |
| `ClientIP` | IP address of the client |
| `Workload` | M365 workload (e.g. PublicEndpoint, SharePoint) |
| `Application` | Application that generated the event (e.g. Outlook, Word) |
| `DeviceName` | Device name or hostname for desktop / endpoint events |

### Conditional properties

| Property | Present when |
| --- | --- |
| `To`, `From`, `Subject` | `EmailInfo` is present (email labeling events) |
| `Justification` | `SensitivityLabelEventData.JustificationText` is present (label downgrade events) |
| `SensitivityLabelId` | `SensitivityLabelEventData` is present |
| `OldSensitivityLabelId` | Label was changed from a previous label (`SensitivityLabelUpdated`, `FileSensitivityLabelChanged`) |
| `CurrentProtectionType`, `PreviousProtectionType`, `LabelId` | `Application` is populated (desktop app events) |
| `ContentType` | `Workload` is `MipAutoLabelPublicEndpoint` |

#### CurrentProtectionType / PreviousProtectionType format

When present, protection type fields are rendered as multi-line `key=value` pairs, for example:

```text
documentEncrypted=True
owner=admin@contoso.com
protectionType=2
templateId=
```

`protectionType` values: `0` = no protection, `1` = template, `2` = Do Not Forward, `3` = Encrypt-Only, `4` = custom.

## Logging

Every run writes a timestamped log file to `-LogDirectory` (default: `$env:TEMP\Get-SensitivityLabelAuditEvents`).
Log files are named `Logging_yyyyMMdd_HHmmss.txt` so runs never share or overwrite each other.

- Every activity line is prefixed with a timestamp.
- Each collected record is written to the log with one property per line; multi-line values are indented.
- A separator line marks the start and end of every run.
- The full log file path is printed to the console in Cyan at the end of each run.
- When `-ExportToCsv` is specified, a matching `AuditResults_yyyyMMdd_HHmmss.csv` is written to the same directory.

## Console output

| Mode | Behavior |
| --- | --- |
| Default | `Format-Table` showing `UserIds`, `UserType`, `Operations`, `CreationDate`, `ResultIndex`, `ClientIP`, `Workload`, `Application`, `DeviceName`, `Justification`, `SensitivityLabelId`, `OldSensitivityLabelId` |
| `-AllData` | All properties printed one per line per record, with multi-line values indented. Per-operation record counts shown in Yellow; "no records found" shown in Red. |

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
