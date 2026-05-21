---
external help file: Get-SensitivityLabelAuditEvents-help.xml
Module Name: Get-SensitivityLabelAuditEvents
online version: https://github.com/dgoldman-msft/Get-SensitivityLabelAuditEvents
schema: 2.0.0
---

# Get-SensitivityLabelAuditEvents

## ALIASES

GSLAE

## SYNOPSIS

Retrieves Unified Audit Log entries for sensitivity label operations from Exchange Online.

## SYNTAX

```text
Get-SensitivityLabelAuditEvents [-UserPrincipalName] <MailAddress>
    [-DaysBack <Int32>]
    [-ResultSize <Int32>]
    [-Operations <String>]
    [-StayConnected]
    [-AllData]
    [-ExportToCsv]
    [-LogDirectory <String>]
    [-FilterDeviceName <String>]
    [-FilterWorkload <String>]
    [-WhatIf]
    [-Confirm]
    [<CommonParameters>]
```

## DESCRIPTION

Get-SensitivityLabelAuditEvents is an advanced function that:

1. Ensures the ExchangeOnlineManagement module is present. If not installed, it is automatically fetched from the PowerShell Gallery into the CurrentUser scope. If already installed, it is imported into the current session.

2. Connects to Exchange Online using the provided UserPrincipalName.

3. Queries Search-UnifiedAuditLog for every known sensitivity label operation (or a specific one when -Operations is supplied) over the specified date range and emits structured output for each record found.

4. Disconnects from Exchange Online when finished, unless -StayConnected is specified.

Conditional properties are only present on records where the underlying audit data contains the relevant field — records that lack EmailInfo will not show To/From/Subject columns, and records without SensitivityLabelEventData will not show Justification or SensitivityLabelId.

## EXAMPLES

### Example 1: Query all operations for the last 100 days

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com
```

Connects as `admin@contoso.com`, queries all 21 sensitivity label operations over the last 100 days, displays a condensed table on the console, writes full per-property records to a timestamped log file, then disconnects.

### Example 2: Limit date range and result size

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -DaysBack 30 -ResultSize 1000
```

Queries only the last 30 days, returning up to 1000 records per operation type.

### Example 3: Query a single operation type

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -Operations SensitivityLabelApplied
```

Queries only SensitivityLabelApplied events from the last 100 days.

### Example 4: Leave the session open

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -StayConnected
```

Queries all audit data and leaves the Exchange Online session open for further commands.

### Example 5: Write logs to a custom directory

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -LogDirectory "C:\Reports\AuditLogs"
```

Writes all log output to a timestamped file such as `C:\Reports\AuditLogs\Logging_20260520_120134.txt`.

### Example 6: Use the GSLAE alias

```powershell
GSLAE -UserPrincipalName admin@contoso.com
```

Uses the GSLAE alias to query all sensitivity label audit events from the last 100 days.

### Example 7: Show all properties per record on the console

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -AllData
```

Displays every property of each record on the console, one per line with multi-line values indented, separated by a blank line between records.

### Example 8: Export results to CSV

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -ExportToCsv
```

Exports all collected records to a timestamped CSV file (e.g. `AuditResults_20260520_120134.csv`) in `-LogDirectory`.

### Example 9: Filter by device name

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -FilterDeviceName 'WIN*'
```

Returns only records where `DeviceName` starts with `WIN`. Wildcards are supported.

### Example 10: Filter by workload

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -FilterWorkload 'PublicEndpoint'
```

Returns only records from the `PublicEndpoint` workload (desktop app labeling events).

### Example 11: Combine filters

```powershell
Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -FilterDeviceName '*WIN11*' -FilterWorkload 'PublicEndpoint' -ExportToCsv
```

Filters to `WIN11` devices on the `PublicEndpoint` workload and exports matches to CSV.

## PARAMETERS

### -UserPrincipalName

The UPN (email address) used to authenticate to Exchange Online.

```yaml
Type: MailAddress
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DaysBack

How many days back from today to search the audit log. Must be between 1 and 365.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResultSize

Maximum number of records returned per operation type. Must be between 1 and 5000.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 5000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Operations

The specific sensitivity label operation to query. Defaults to 'All', which queries all 21 known operations covering file/item labels (M365 apps, Office for the web, SharePoint, auto-labeling), failure events, site/container labels, and legacy MIP operations. Supports tab-completion.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, SensitivityLabelApplied, SensitivityLabelUpdated, SensitivityLabelRemoved, FileSensitivityLabelApplied, FileSensitivityLabelChanged, FileSensitivityLabelRemoved, FileSensitivityLabelAppliedFailed, FileSensitivityLabelChangedFailed, FileSensitivityLabelRemovedFailed, SiteSensitivityLabelApplied, SiteSensitivityLabelChanged, SiteSensitivityLabelRemoved, SensitivityLabelFileRead, SensitivityLabeledFileOpened, SensitivityLabeledFileModified, SensitivityLabeledFileRenamed, SensitivityLabeledFileDeleted, SensitivityLabelPolicyMatched, SensitivityLabelPolicyChanged

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -StayConnected

When specified, the Exchange Online session is NOT disconnected after the query completes. Useful when chaining multiple Exchange Online operations in the same session.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllData

When specified, console output shows all available properties for each record, one per line with multi-line values indented. A blank line separates each record. Also enables per-operation console messages showing how many records were returned (Yellow) or that no records were found (Red). By default, a condensed table showing `UserIds`, `UserType`, `Operations`, `CreationDate`, `ResultIndex`, `ClientIP`, `Workload`, `Application`, `DeviceName`, `Justification`, and `SensitivityLabelId` is displayed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportToCsv

When specified, exports all collected audit records to a CSV file in `-LogDirectory`. The file name matches the run timestamp, e.g. `AuditResults_20260520_120134.csv`. If no records were collected the export is skipped.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogDirectory

Specifies the full path to the directory where log files will be written. Each run creates a new timestamped log file named `Logging_yyyyMMdd_HHmmss.txt` so runs never share or overwrite each other. Defaults to a subdirectory named `Get-SensitivityLabelAuditEvents` inside the system temp folder (`$env:TEMP`).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $env:TEMP\Get-SensitivityLabelAuditEvents
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDeviceName

When specified, only records whose DeviceName matches this value are included in the output and log. Supports wildcards (e.g. `WIN*`, `*laptop*`). Matching is case-insensitive. Applied after all audit queries complete.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -FilterWorkload

When specified, only records whose Workload matches this value are included in the output and log. Supports wildcards (e.g. `SharePoint*`, `MipAutoLabel*`). Matching is case-insensitive. Applied after all audit queries complete.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

This function does not accept pipeline input.

## OUTPUTS

### System.Management.Automation.PSCustomObject

Each output object contains the following core properties: UserIds, UserType, Operations, CreationDate, ResultIndex, ClientIP, Workload, Application, DeviceName.

The following properties are conditionally present:

| Property | Present when |
| --- | --- |
| To, From, Subject | EmailInfo exists in the audit record |
| Justification | SensitivityLabelEventData.JustificationText is present (label downgrade events) |
| SensitivityLabelId | SensitivityLabelEventData is present |
| OldSensitivityLabelId | Label was changed from a previous label (SensitivityLabelUpdated, FileSensitivityLabelChanged) |
| CurrentProtectionType, PreviousProtectionType, LabelId | Application is populated (desktop app events) |
| ContentType | Workload is MipAutoLabelPublicEndpoint |

When present, `CurrentProtectionType` and `PreviousProtectionType` are rendered as multi-line `key=value` pairs. `protectionType` values: 0 = no protection, 1 = template, 2 = Do Not Forward, 3 = Encrypt-Only, 4 = custom.

Filters (`-FilterDeviceName`, `-FilterWorkload`) are applied after all queries complete. Records that do not match are excluded from both the console output and the log.

## NOTES

This function has the alias **GSLAE**.

Requires PowerShell 7.1 or later.

Module installation uses the CurrentUser scope — no elevated privileges required.

Each run creates a separate timestamped log file (`Logging_yyyyMMdd_HHmmss.txt`) inside `-LogDirectory`. The log directory is created automatically if it does not exist. Every activity line is prefixed with a timestamp. Each collected record is written to the log with one property per line; multi-line values are indented. A separator line marks the start and end of every run. The full log file path is printed to the console in Cyan at the end of each run.

A progress bar is displayed while querying operations, showing the current operation name and percent complete.

The account used must have the **Audit Logs** role in Exchange Online (typically held by the Compliance Administrator or Security Administrator roles).

ExchangeOnlineManagement module: [ExchangeOnlineManagement](https://www.powershellgallery.com/packages/ExchangeOnlineManagement)

## RELATED LINKS

[Search-UnifiedAuditLog](https://learn.microsoft.com/en-us/powershell/module/exchange/search-unifiedauditlog)

[Connect-ExchangeOnline](https://learn.microsoft.com/en-us/powershell/module/exchange/connect-exchangeonline)
