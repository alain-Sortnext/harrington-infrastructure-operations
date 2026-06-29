#Requires -RunAsAdministrator
#Requires -Module ActiveDirectory
<#
.SYNOPSIS
    Harrington Capital plc -- Bulk User Provisioning
    Phase 7: Automation Suite

.DESCRIPTION
    BUILD  : Reads users from a CSV, creates AD accounts, assigns to correct OU.
    VERIFY : Outputs created user list with UPN, OU, and enabled status.
    SUBMIT : Paste VERIFICATION OUTPUT into your Phase 7 submission.

.PARAMETER CsvPath
    Path to CSV file. Required columns: FirstName, LastName, Department, Title, Manager

.EXAMPLE
    .\04-user-provisioning.ps1 -CsvPath "C:\HC-Logs\new-starters.csv"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,

    [string]$DefaultPassword = "HC@NewStarter2026!",
    [string]$Domain          = "harrington.local",
    [string]$LogDir          = "C:\HC-Logs"
)

Import-Module ActiveDirectory

$LogFile = Join-Path $LogDir "user-provisioning-$(Get-Date -Format 'yyyyMMdd-HHmm').log"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry
}

# Department to OU mapping
$DeptOUMap = @{
    "Technology"         = "OU=Technology,OU=Users,OU=Harrington Capital,DC=harrington,DC=local"
    "Finance"            = "OU=Finance,OU=Users,OU=Harrington Capital,DC=harrington,DC=local"
    "Investments"        = "OU=Investments,OU=Users,OU=Harrington Capital,DC=harrington,DC=local"
    "Risk and Compliance"= "OU=Risk and Compliance,OU=Users,OU=Harrington Capital,DC=harrington,DC=local"
    "Operations"         = "OU=Operations,OU=Users,OU=Harrington Capital,DC=harrington,DC=local"
}

Write-Log "=== USER PROVISIONING RUN ==="
Write-Log "CSV input  : $CsvPath"
Write-Log "Domain     : $Domain"

if (-not (Test-Path $CsvPath)) {
    Write-Log "CSV file not found: $CsvPath" "ERROR"
    exit 1
}

$Users   = Import-Csv -Path $CsvPath
$Created = @()
$Failed  = @()
$SecPass = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force

foreach ($u in $Users) {
    $sam = "$($u.FirstName.Substring(0,1).ToLower()).$($u.LastName.ToLower())"
    $upn = "$sam@$Domain"
    $ou  = $DeptOUMap[$u.Department]

    if (-not $ou) {
        Write-Log "Unknown department '$($u.Department)' for $upn -- skipping" "WARN"
        $Failed += $u
        continue
    }

    try {
        New-ADUser `
            -GivenName            $u.FirstName `
            -Surname              $u.LastName `
            -Name                 "$($u.FirstName) $($u.LastName)" `
            -SamAccountName       $sam `
            -UserPrincipalName    $upn `
            -Title                $u.Title `
            -Department           $u.Department `
            -Path                 $ou `
            -AccountPassword      $SecPass `
            -Enabled              $true `
            -PasswordNeverExpires $false `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop

        Write-Log "Created: $upn | Dept: $($u.Department) | Title: $($u.Title)"
        $Created += [PSCustomObject]@{ UPN = $upn; Department = $u.Department; Status = "Created" }
    } catch {
        Write-Log "Failed to create $upn : $($_.Exception.Message)" "ERROR"
        $Failed += [PSCustomObject]@{ UPN = $upn; Department = $u.Department; Status = "Failed" }
    }
}

# -----------------------------------------------------------------
# VERIFICATION OUTPUT
# -----------------------------------------------------------------
Write-Host ""
Write-Host "================================================================"
Write-Host "  PROVISIONING SUMMARY -- PASTE INTO SUBMISSION"
Write-Host "================================================================"
Write-Host "Created : $($Created.Count)"
Write-Host "Failed  : $($Failed.Count)"
Write-Host ""
Write-Host "--- CREATED ACCOUNTS ---"
$Created | Format-Table -AutoSize
Write-Host "--- FAILED ACCOUNTS ---"
$Failed | Format-Table -AutoSize
Write-Host "Log: $LogFile"
