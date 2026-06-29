#Requires -Version 7.0
<#
.SYNOPSIS
    Harrington Capital plc -- Disk Health Monitor
    Phase 7: Automation Suite

.DESCRIPTION
    BUILD  : Checks disk usage across all managed servers, flags drives
             above warning (75%) and critical (90%) thresholds.
    VERIFY : Output shows all drives with percentage used and status.
    SUBMIT : Paste console output into your Phase 7 submission.

.NOTES
    Scheduling: Run via Windows Task Scheduler or Azure Automation.
    Output: Writes to C:\HC-Logs\disk-check-YYYYMMDD.log
    Alerting: Extend with Send-MailMessage or Teams webhook.
#>

param(
    [int]$WarningThresholdPct  = 75,
    [int]$CriticalThresholdPct = 90,
    [string]$LogDir            = "C:\HC-Logs"
)

$LogFile = Join-Path $LogDir "disk-check-$(Get-Date -Format 'yyyyMMdd-HHmm').log"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry
}

# Servers to check -- extend this list as estate grows
$Servers = @("localhost", "HC-DC01", "HC-APP01", "HC-MON01")

Write-Log "=== DISK HEALTH CHECK ==="
Write-Log "Warning threshold : $WarningThresholdPct%"
Write-Log "Critical threshold: $CriticalThresholdPct%"
Write-Log "Checking servers  : $($Servers -join ', ')"
Write-Host ""

$Results = @()

foreach ($server in $Servers) {
    Write-Log "Checking: $server"

    try {
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk `
                    -ComputerName $server `
                    -Filter "DriveType=3" `
                    -ErrorAction Stop

        foreach ($disk in $disks) {
            $totalGB = [math]::Round($disk.Size / 1GB, 2)
            $freeGB  = [math]::Round($disk.FreeSpace / 1GB, 2)
            $usedGB  = [math]::Round($totalGB - $freeGB, 2)
            $usedPct = if ($totalGB -gt 0) { [math]::Round(($usedGB / $totalGB) * 100, 1) } else { 0 }

            $status = switch ($usedPct) {
                { $_ -ge $CriticalThresholdPct } { "CRITICAL" }
                { $_ -ge $WarningThresholdPct  } { "WARNING"  }
                default                           { "OK"       }
            }

            $result = [PSCustomObject]@{
                Server   = $server
                Drive    = $disk.DeviceID
                TotalGB  = $totalGB
                UsedGB   = $usedGB
                FreeGB   = $freeGB
                UsedPct  = $usedPct
                Status   = $status
            }

            $Results += $result
            Write-Log "$server $($disk.DeviceID) | Used: $usedPct% ($usedGB GB / $totalGB GB) | Status: $status" `
                      $(if ($status -eq "CRITICAL") { "ERROR" } elseif ($status -eq "WARNING") { "WARN" } else { "INFO" })
        }
    } catch {
        Write-Log "Could not connect to $server : $($_.Exception.Message)" "WARN"
        $Results += [PSCustomObject]@{
            Server  = $server; Drive = "N/A"; TotalGB = 0
            UsedGB  = 0; FreeGB = 0; UsedPct = 0; Status = "UNREACHABLE"
        }
    }
}

# -----------------------------------------------------------------
# VERIFICATION OUTPUT
# -----------------------------------------------------------------
Write-Host ""
Write-Host "================================================================"
Write-Host "  DISK HEALTH SUMMARY -- PASTE INTO SUBMISSION"
Write-Host "================================================================"
$Results | Format-Table -AutoSize

$critical = $Results | Where-Object { $_.Status -eq "CRITICAL" }
$warnings = $Results | Where-Object { $_.Status -eq "WARNING" }

Write-Host "Critical alerts : $($critical.Count)"
Write-Host "Warning alerts  : $($warnings.Count)"
Write-Host "Servers checked : $($Servers.Count)"
Write-Host "Log written to  : $LogFile"
Write-Host "Run timestamp   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
