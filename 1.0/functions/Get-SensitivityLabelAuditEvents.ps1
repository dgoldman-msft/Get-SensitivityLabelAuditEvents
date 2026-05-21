#Requires -Version 7.1

function Get-SensitivityLabelAuditEvents {
    <#
    .SYNOPSIS
        Retrieves Unified Audit Log entries for sensitivity label operations from Exchange Online.

    .DESCRIPTION
        Get-SensitivityLabelAuditEvents is an advanced function that:

          1. Ensures the ExchangeOnlineManagement module is present. If not installed, it is
             automatically fetched from the PowerShell Gallery into the CurrentUser scope.
             If already installed, it is imported into the current session.

          2. Connects to Exchange Online using the provided UserPrincipalName.

          3. Queries Search-UnifiedAuditLog for every known sensitivity label operation (or a
             specific one when -Operations is supplied) over the specified date range and emits
             structured output for each record found.

          4. Disconnects from Exchange Online when finished, unless -StayConnected is specified.

    .PARAMETER UserPrincipalName
        The UPN (email address) used to authenticate to Exchange Online.
        Example: admin@contoso.com

    .PARAMETER DaysBack
        How many days back from today to search the audit log. Must be between 1 and 365.
        Defaults to 100.

    .PARAMETER ResultSize
        Maximum number of records returned per operation type. Must be between 1 and 5000.
        Defaults to 5000.

    .PARAMETER Operations
        One or more specific sensitivity label operations to query. Defaults to 'All', which queries
        every known operation. Use tab-completion to select a single operation type.

        Valid values:
          All

          File / item operations applied via Microsoft 365 apps:
            SensitivityLabelApplied, SensitivityLabelUpdated, SensitivityLabelRemoved

          File / item operations applied via Office for the web, SharePoint details pane,
          Teams Files tab, or auto-labeling policies:
            FileSensitivityLabelApplied, FileSensitivityLabelChanged, FileSensitivityLabelRemoved

          Failure operations:
            FileSensitivityLabelAppliedFailed, FileSensitivityLabelChangedFailed,
            FileSensitivityLabelRemovedFailed

          Site / container operations (SharePoint sites, Teams sites, Loop workspaces):
            SiteSensitivityLabelApplied, SiteSensitivityLabelChanged, SiteSensitivityLabelRemoved

          Legacy / additional operations:
            SensitivityLabelFileRead, SensitivityLabeledFileOpened, SensitivityLabeledFileModified,
            SensitivityLabeledFileRenamed, SensitivityLabeledFileDeleted,
            SensitivityLabelPolicyMatched, SensitivityLabelPolicyChanged

        Note: SensitivityLabelRemoved covers label removals in Microsoft 365 desktop apps (Word,
        Excel, PowerPoint, Outlook). Removals via Office for the web, SharePoint, or Teams appear
        under FileSensitivityLabelRemoved instead.

    .PARAMETER StayConnected
        When specified, the Exchange Online session is NOT disconnected after the query completes.
        Useful when chaining multiple Exchange Online operations in the same session.

    .PARAMETER AllData
        When specified, console output shows all available properties for each record, one per line
        with multi-line values indented. A blank line separates each record. Also enables
        per-operation console messages showing how many records were returned (Yellow) or that no
        records were found (Red). By default, a condensed table showing UserIds, UserType,
        Operations, CreationDate, ResultIndex, ClientIP, Workload, Application, DeviceName,
        Justification, and SensitivityLabelId is displayed.

    .PARAMETER ExportToCsv
        When specified, exports all collected audit records to a CSV file in -LogDirectory.
        The file is named using the same timestamp as the log file, e.g.
        AuditResults_20260520_120134.csv.

    .PARAMETER LogDirectory
        Specifies the full path to the directory where log files will be written. Each run creates
        a new timestamped log file named Logging_yyyyMMdd_HHmmss.txt so runs never share or
        overwrite each other. The log directory is created automatically if it does not exist.
        Defaults to a subdirectory named 'Get-SensitivityLabelAuditEvents' inside the system temp
        folder ($env:TEMP).

    .PARAMETER FilterDeviceName
        When specified, only records whose DeviceName matches this value are included in the output
        and log. Supports wildcards (e.g. 'WIN*', '*laptop*'). Matching is case-insensitive.
        Applied after all audit queries complete.

    .PARAMETER FilterWorkload
        When specified, only records whose Workload matches this value are included in the output
        and log. Supports wildcards (e.g. 'SharePoint*', 'MipAutoLabel*'). Matching is
        case-insensitive. Applied after all audit queries complete.

    .EXAMPLE
        C:\PS> Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com

        Connects as admin@contoso.com, queries all sensitivity label audit events from the last
        100 days, then disconnects.

    .EXAMPLE
        C:\PS> Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -DaysBack 30 -ResultSize 1000

        Queries only the last 30 days, returning up to 1000 records per operation type.

    .EXAMPLE
        C:\PS> Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -Operations SensitivityLabelApplied

        Queries only SensitivityLabelApplied events from the last 100 days.

    .EXAMPLE
        C:\PS> Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -StayConnected

        Queries audit data and leaves the Exchange Online session open for further commands.

    .EXAMPLE
        C:\PS> Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -LogDirectory "C:\Reports\AuditLogs"

        Queries audit data and writes all log output to a timestamped file such as
        C:\Reports\AuditLogs\Logging_20260520_120134.txt.

    .EXAMPLE
        C:\PS> GSLAE -UserPrincipalName admin@contoso.com

        Uses the GSLAE alias to query all sensitivity label audit events from the last 100 days.

    .EXAMPLE
        C:\PS> Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -AllData

        Displays every property of each record on the console, one per line with multi-line values
        indented, separated by a blank line between records. Also shows per-operation counts.

    .EXAMPLE
        C:\PS> Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -ExportToCsv

        Exports all collected records to a timestamped CSV file (e.g. AuditResults_20260520_120134.csv)
        in -LogDirectory.

    .EXAMPLE
        C:\PS> Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -FilterDeviceName 'WIN*'

        Returns only records where DeviceName starts with 'WIN'. Supports wildcards.

    .EXAMPLE
        C:\PS> Get-SensitivityLabelAuditEvents -UserPrincipalName admin@contoso.com -FilterWorkload 'PublicEndpoint'

        Returns only records from the PublicEndpoint workload (desktop app labeling events).

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        PSCustomObject with properties: UserIds, UserType, Operations, CreationDate, ResultIndex,
        ClientIP, Workload, Application, DeviceName. Conditional properties (To, From, Subject,
        Justification, SensitivityLabelId, CurrentProtectionType, PreviousProtectionType, LabelId,
        ContentType) are added only when the relevant audit data is present.

    .NOTES
        This function has the alias GSLAE.
        Requires PowerShell 7.1 or later.
        Module installation uses the CurrentUser scope — no elevated privileges required.
        Each run creates a separate timestamped log file (Logging_yyyyMMdd_HHmmss.txt) inside
        -LogDirectory. Every activity line is prefixed with a timestamp. Each collected record is
        written to the log with one property per line; multi-line values are indented. A separator
        line marks the start and end of every run. The full log file path is printed to the console
        in Cyan at the end of each run.
        A progress bar is displayed while querying operations, showing the current operation name
        and percent complete.
        The account used must have the Audit Logs role in Exchange Online (typically held by the
        Compliance Administrator or Security Administrator roles).
        ExchangeOnlineManagement: https://www.powershellgallery.com/packages/ExchangeOnlineManagement
    #>

    [Alias('GSLAE')]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, Position = 0, HelpMessage = 'UPN of the account used to connect to Exchange Online.')]
        [ValidateNotNullOrEmpty()]
        [System.Net.Mail.MailAddress]
        $UserPrincipalName,

        [Parameter()]
        [ValidateRange(1, 365)]
        [int]
        $DaysBack = 100,

        [Parameter()]
        [ValidateRange(1, 5000)]
        [int]
        $ResultSize = 5000,

        [Parameter()]
        [ValidateSet(
            'All',
            # File / item operations (Microsoft 365 apps)
            'SensitivityLabelApplied',
            'SensitivityLabelUpdated',
            'SensitivityLabelRemoved',
            # File / item operations (Office for web, SharePoint details pane, Teams Files tab, auto-labeling)
            'FileSensitivityLabelApplied',
            'FileSensitivityLabelChanged',
            'FileSensitivityLabelRemoved',
            # Failure operations
            'FileSensitivityLabelAppliedFailed',
            'FileSensitivityLabelChangedFailed',
            'FileSensitivityLabelRemovedFailed',
            # Site / container operations
            'SiteSensitivityLabelApplied',
            'SiteSensitivityLabelChanged',
            'SiteSensitivityLabelRemoved',
            # Legacy / additional operations
            'SensitivityLabelFileRead',
            'SensitivityLabeledFileOpened',
            'SensitivityLabeledFileModified',
            'SensitivityLabeledFileRenamed',
            'SensitivityLabeledFileDeleted',
            'SensitivityLabelPolicyMatched',
            'SensitivityLabelPolicyChanged'
        )]
        [string]
        $Operations = 'All',

        [Parameter()]
        [switch]$StayConnected,

        [Parameter()]
        [switch]$AllData,

        [Parameter()]
        [switch]$ExportToCsv,

        [Parameter()]
        [string]$LogDirectory = (Join-Path $env:TEMP 'Get-SensitivityLabelAuditEvents'),

        [Parameter()]
        [string]$FilterDeviceName,

        [Parameter()]
        [string]$FilterWorkload
    )

    begin {
        # Ensure log directory exists before any logging
        if (-not (Test-Path -Path $LogDirectory)) {
            New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
        }

        # Generate a unique timestamped log file for this run
        $runStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $logFile  = Join-Path $LogDirectory "Logging_$runStamp.txt"

        $separator = "$(Get-TimeStamp) " + ("-" * 80)
        Write-ToLogFile -StringObject $separator -LogFile $logFile
        Write-ToLogFile -StringObject "$(Get-TimeStamp) Starting Get-SensitivityLabelAuditEvents" -LogFile $logFile

        #region Module check — install if missing, import if not already loaded
        $moduleName = 'ExchangeOnlineManagement'

        Write-ToLogFile -StringObject "$(Get-TimeStamp) Checking for $moduleName module" -LogFile $logFile

        $installed = Get-Module -ListAvailable -Name $moduleName |
            Sort-Object Version -Descending |
            Select-Object -First 1

        if (-not $installed) {
            Write-ToLogFile -StringObject "$(Get-TimeStamp) $moduleName not found. Installing latest version from PSGallery..." -LogFile $logFile -ForegroundColor Yellow
            try {
                Install-Module -Name $moduleName `
                    -Scope CurrentUser -Repository PSGallery -Force -AllowClobber -ErrorAction Stop
                Write-ToLogFile -StringObject "$(Get-TimeStamp) $moduleName installed successfully." -LogFile $logFile
            }
            catch {
                Write-ToLogFile -StringObject "$(Get-TimeStamp) ERROR: $moduleName installation failed. Error: $_" -LogFile $logFile -ForegroundColor Red
                throw "[$moduleName] Installation failed. Error: $_"
            }
        }
        else {
            Write-ToLogFile -StringObject "$(Get-TimeStamp) $moduleName found v$($installed.Version)." -LogFile $logFile
        }

        if (-not (Get-Module -Name $moduleName)) {
            try {
                Import-Module -Name $moduleName -ErrorAction Stop
                Write-ToLogFile -StringObject "$(Get-TimeStamp) $moduleName imported into the current session." -LogFile $logFile
            }
            catch {
                Write-ToLogFile -StringObject "$(Get-TimeStamp) ERROR: $moduleName import failed. Error: $_" -LogFile $logFile -ForegroundColor Red
                throw "[$moduleName] Import failed. Error: $_"
            }
        }
        else {
            Write-ToLogFile -StringObject "$(Get-TimeStamp) $moduleName already loaded in this session." -LogFile $logFile
        }
        #endregion

        # Formats a protection-type object as readable key=value lines
        $formatProtection = {
            param($obj)
            if (-not $obj) { return $null }
            ($obj.PSObject.Properties | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join "`n"
        }

        #region Connect to Exchange Online
        Write-ToLogFile -StringObject "$(Get-TimeStamp) Connecting to Exchange Online as $($UserPrincipalName.Address)" -LogFile $logFile
        if ($PSCmdlet.ShouldProcess($UserPrincipalName.Address, 'Connect-ExchangeOnline')) {
            try {
                Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName.Address -ShowBanner:$false -ErrorAction Stop
                Write-ToLogFile -StringObject "$(Get-TimeStamp) Connected to Exchange Online as $($UserPrincipalName.Address)." -LogFile $logFile
            }
            catch {
                Write-ToLogFile -StringObject "$(Get-TimeStamp) ERROR: Exchange Online connection failed. Error: $_" -LogFile $logFile -ForegroundColor Red
                throw "[ExchangeOnline] Connection failed. Error: $_"
            }
        }
        #endregion
    }

    process {
        #region Query Unified Audit Log for each sensitivity label operation
        $sensitivityLabelOperations = if ($Operations -eq 'All') {
            @(
                # File / item operations — Microsoft 365 apps
                'SensitivityLabelApplied',
                'SensitivityLabelUpdated',
                'SensitivityLabelRemoved',
                # File / item operations — Office for web, SharePoint details pane, Teams Files tab, auto-labeling
                'FileSensitivityLabelApplied',
                'FileSensitivityLabelChanged',
                'FileSensitivityLabelRemoved',
                # Failure operations
                'FileSensitivityLabelAppliedFailed',
                'FileSensitivityLabelChangedFailed',
                'FileSensitivityLabelRemovedFailed',
                # Site / container operations
                'SiteSensitivityLabelApplied',
                'SiteSensitivityLabelChanged',
                'SiteSensitivityLabelRemoved',
                # Legacy / additional operations
                'SensitivityLabelFileRead',
                'SensitivityLabeledFileOpened',
                'SensitivityLabeledFileModified',
                'SensitivityLabeledFileRenamed',
                'SensitivityLabeledFileDeleted',
                'SensitivityLabelPolicyMatched',
                'SensitivityLabelPolicyChanged'
            )
        } else {
            @($Operations)
        }

        $startDate  = (Get-Date).AddDays(-$DaysBack)
        $endDate    = Get-Date
        $allResults = [System.Collections.Generic.List[pscustomobject]]::new()

        Write-ToLogFile -StringObject "$(Get-TimeStamp) Querying audit log from $($startDate.ToString('MM/dd/yyyy')) to $($endDate.ToString('MM/dd/yyyy')) | Operations: $($sensitivityLabelOperations.Count) | ResultSize: $ResultSize" -LogFile $logFile

        $operationCount = $sensitivityLabelOperations.Count
        $operationIndex = 0

        $savedProgressPreference = $ProgressPreference
        $ProgressPreference = 'Continue'

        foreach ($operation in $sensitivityLabelOperations) {
            $operationIndex++
            Write-Progress -Activity 'Querying Unified Audit Log' `
                -Status "Operation $operationIndex of $operationCount : $operation" `
                -PercentComplete ([int](($operationIndex / $operationCount) * 100))
            Write-ToLogFile -StringObject "$(Get-TimeStamp) Querying operation: $operation ($operationIndex of $operationCount)" -LogFile $logFile -LogOnly
            try {
                $results = Search-UnifiedAuditLog -Operations $operation -StartDate $startDate -EndDate $endDate `
                    -ResultSize $ResultSize -Formatted -ErrorAction Stop

                if ($results) {
                    Write-ToLogFile -StringObject "$(Get-TimeStamp) $operation — $($results.Count) record(s) returned" -LogFile $logFile -LogOnly
                    if ($AllData) { Write-Host "$(Get-TimeStamp) $operation — $($results.Count) record(s) returned" -ForegroundColor Yellow }
                }
                else {
                    Write-ToLogFile -StringObject "$(Get-TimeStamp) $operation — no records found" -LogFile $logFile -LogOnly
                    if ($AllData) { Write-Host "$(Get-TimeStamp) $operation — no records found" -ForegroundColor Red }
                    if ($operation -eq 'SensitivityLabelRemoved') {
                        Write-ToLogFile -StringObject "$(Get-TimeStamp)   Note: SensitivityLabelRemoved covers label removals performed in Microsoft 365 desktop apps (Word, Excel, PowerPoint, Outlook). No activity found in this period. Label removals performed via Office for the web, SharePoint, or Teams are logged under FileSensitivityLabelRemoved instead." -LogFile $logFile -LogOnly
                    }
                }

                $results | ForEach-Object {
                    $auditData = $_.AuditData | ConvertFrom-Json

                    # Build the output object with only the properties that have data
                    $record = [ordered]@{
                        UserIds      = $_.UserIds
                        UserType     = $auditData.UserType
                        Operations   = $_.Operations
                        CreationDate = $_.CreationDate
                        ResultIndex  = $_.ResultIndex
                        ClientIP     = $auditData.ClientIP
                        Workload     = $auditData.Workload
                        Application  = $auditData.Application
                        DeviceName   = $auditData.DeviceName
                    }

                    if ($auditData.EmailInfo) {
                        $record['To']      = ($auditData.EmailInfo.To -join '; ')
                        $record['From']    = $auditData.EmailInfo.From
                        $record['Subject'] = $auditData.EmailInfo.Subject
                    }

                    if ($auditData.SensitivityLabelEventData) {
                        $record['Justification']         = $auditData.SensitivityLabelEventData.JustificationText
                        $record['SensitivityLabelId']    = $auditData.SensitivityLabelEventData.SensitivityLabelId
                        $record['OldSensitivityLabelId'] = $auditData.SensitivityLabelEventData.OldSensitivityLabelId
                    }

                    if ($auditData.Application) {
                        $record['CurrentProtectionType']  = & $formatProtection $auditData.CurrentProtectionType
                        $record['PreviousProtectionType'] = & $formatProtection $auditData.PreviousProtectionType
                        $record['LabelId']                = $auditData.LabelId
                    }

                    if ($auditData.Workload -eq 'MipAutoLabelPublicEndpoint') {
                        $record['DeviceName']             = $auditData.DeviceName
                        $record['ContentType']            = $auditData.ContentType
                        $record['CurrentProtectionType']  = & $formatProtection $auditData.CurrentProtectionType
                        $record['PreviousProtectionType'] = & $formatProtection $auditData.PreviousProtectionType
                    }

                    $allResults.Add([pscustomobject]$record)
                }
            }
            catch {
                Write-ToLogFile -StringObject "$(Get-TimeStamp) ERROR: Failed querying operation '$operation': $($_.Exception.Message)" -LogFile $logFile -ForegroundColor Red
                Write-Warning "[AuditLog] Query failed for operation '$operation'. Error: $($_.Exception.Message)"
            }
        }

        Write-Progress -Activity 'Querying Unified Audit Log' -Completed
        $ProgressPreference = $savedProgressPreference

        Write-ToLogFile -StringObject "$(Get-TimeStamp) Query complete. Total records collected: $($allResults.Count)" -LogFile $logFile

        # Apply optional post-query filters
        if ($FilterDeviceName) {
            $before = $allResults.Count
            $allResults = [System.Collections.Generic.List[pscustomobject]]($allResults | Where-Object { $_.DeviceName -like $FilterDeviceName })
            Write-ToLogFile -StringObject "$(Get-TimeStamp) FilterDeviceName '$FilterDeviceName' applied — $($allResults.Count) of $before record(s) match" -LogFile $logFile
        }
        if ($FilterWorkload) {
            $before = $allResults.Count
            $allResults = [System.Collections.Generic.List[pscustomobject]]($allResults | Where-Object { $_.Workload -like $FilterWorkload })
            Write-ToLogFile -StringObject "$(Get-TimeStamp) FilterWorkload '$FilterWorkload' applied — $($allResults.Count) of $before record(s) match" -LogFile $logFile
        }

        # Console output — table by default, full list with -AllData
        if ($AllData) {
            foreach ($record in $allResults) {
                Write-Host "$(Get-TimeStamp) RESULT —"
                foreach ($prop in $record.PSObject.Properties) {
                    $lines = "$($prop.Value)" -split "`n"
                    Write-Host "    $($prop.Name): $($lines[0].TrimEnd())"
                    if ($lines.Count -gt 1) {
                        foreach ($subLine in $lines[1..($lines.Count - 1)]) {
                            Write-Host "        $($subLine.TrimEnd())"
                        }
                    }
                }
                Write-Host
            }
        }
        else {
            $allResults | Format-Table -AutoSize -Property UserIds, UserType, Operations, CreationDate, ResultIndex, ClientIP, Workload, Application, DeviceName, Justification, SensitivityLabelId, OldSensitivityLabelId
        }

        # Write every record to the log file — each property on its own line
        foreach ($record in $allResults) {
            Write-ToLogFile -StringObject "" -LogFile $logFile -LogOnly
            Write-ToLogFile -StringObject "$(Get-TimeStamp) RESULT —" -LogFile $logFile -LogOnly
            foreach ($prop in $record.PSObject.Properties) {
                $lines = "$($prop.Value)" -split "`n"
                Write-ToLogFile -StringObject "    $($prop.Name): $($lines[0].TrimEnd())" -LogFile $logFile -LogOnly
                if ($lines.Count -gt 1) {
                    foreach ($subLine in $lines[1..($lines.Count - 1)]) {
                        Write-ToLogFile -StringObject "        $($subLine.TrimEnd())" -LogFile $logFile -LogOnly
                    }
                }
            }
        }
        #endregion
    }

    end {
        #region Disconnect from Exchange Online unless -StayConnected was passed
        if (-not $StayConnected) {
            try {
                Disconnect-ExchangeOnline -Confirm:$false -ErrorAction Stop
                Write-ToLogFile -StringObject "$(Get-TimeStamp) Disconnected from Exchange Online successfully." -LogFile $logFile
            }
            catch {
                Write-ToLogFile -StringObject "$(Get-TimeStamp) WARNING: Disconnect from Exchange Online failed. Error: $($_.Exception.Message)" -LogFile $logFile -ForegroundColor Yellow
                Write-Warning "[ExchangeOnline] Disconnect failed. Error: $_"
            }
        }
        else {
            Write-ToLogFile -StringObject "$(Get-TimeStamp) Session left open (-StayConnected specified)." -LogFile $logFile
        }
        #endregion

        Write-ToLogFile -StringObject "$(Get-TimeStamp) Get-SensitivityLabelAuditEvents completed." -LogFile $logFile
        Write-ToLogFile -StringObject $separator -LogFile $logFile

        # Export to CSV if requested
        if ($ExportToCsv) {
            if ($allResults.Count -gt 0) {
                $csvPath = Join-Path $LogDirectory "AuditResults_$runStamp.csv"
                try {
                    $allResults | Export-Csv -Path $csvPath -NoTypeInformation -Encoding utf8 -ErrorAction Stop
                    Write-Host "CSV exported to: $csvPath" -ForegroundColor Green
                    Write-ToLogFile -StringObject "$(Get-TimeStamp) CSV exported to: $csvPath" -LogFile $logFile
                }
                catch {
                    Write-Warning "Failed to export CSV: $($_.Exception.Message)"
                    Write-ToLogFile -StringObject "$(Get-TimeStamp) ERROR: CSV export failed: $($_.Exception.Message)" -LogFile $logFile -ForegroundColor Red
                }
            }
            else {
                Write-Host "No records to export." -ForegroundColor Yellow
                Write-ToLogFile -StringObject "$(Get-TimeStamp) ExportToCsv specified but no records were collected — skipping." -LogFile $logFile
            }
        }

        Write-Host "Log file written to: $logFile" -ForegroundColor Cyan
    }
}
