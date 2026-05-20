# Dot-source internal helper functions
. (Join-Path $PSScriptRoot 'internal\functions\Get-TimeStamp.ps1')
. (Join-Path $PSScriptRoot 'internal\functions\Write-ToLogFile.ps1')

# Dot-source public function
. (Join-Path $PSScriptRoot 'functions\Get-SensitivityLabelAuditEvents.ps1')

# Export public function and alias
Export-ModuleMember -Function 'Get-SensitivityLabelAuditEvents' -Alias 'GSLAE'
