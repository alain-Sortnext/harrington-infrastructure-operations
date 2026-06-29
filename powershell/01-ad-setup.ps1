#Requires -RunAsAdministrator
#Requires -Version 7.0
<#
.SYNOPSIS
    Harrington Capital plc -- Active Directory Setup
    Phase 2: Install AD DS, configure domain, create OU structure and users.

.DESCRIPTION
    BUILD  : Installs AD DS, promotes server to DC, creates OU structure,
             creates 10 test user accounts across departments.
    VERIFY : Confirms domain functional level, DNS resolution, user auth.
    SUBMIT : Copy console output into your Phase 2 submission.

.NOTES
    Run on HC-DC01 (Windows Server 2022)
    Domain: harrington.local
    NetBIOS: HARRINGTON
#>

# -----------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------
$DomainName     = "harrington.local"
$NetBIOSName    = "HARRINGTON"
$SafeModePass   = ConvertTo-SecureString "HC@SafeMode2026!" -AsPlainText -Force
$LogPath        = "C:\HC-Logs\ad-setup-$(Get-Date -Format 'yyyyMMdd-HHmm').log"

# Ensure log directory exists
New-Item -ItemType Directory -Path "C:\HC-Logs" -Force | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $entry
    Add-Content -Path $LogPath -Value $entry
}

# -----------------------------------------------------------------
# STEP 1: INSTALL AD DS ROLE
# -----------------------------------------------------------------
Write-Log "=== PHASE 2: Active Directory Setup ==="
Write-Log "Installing AD DS Windows Feature..."

try {
    $feature = Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    if ($feature.Success) {
        Write-Log "AD DS role installed successfully."
    } else {
        Write-Log "AD DS installation reported failure. Check Windows Update status." "WARN"
    }
} catch {
    Write-Log "Error installing AD DS: $($_.Exception.Message)" "ERROR"
    exit 1
}

# -----------------------------------------------------------------
# STEP 2: PROMOTE TO DOMAIN CONTROLLER
# -----------------------------------------------------------------
Write-Log "Promoting server to Domain Controller for domain: $DomainName"
Write-Log "VERIFY: Server will restart after promotion. Re-run verification section after restart."

try {
    Import-Module ADDSDeployment

    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $NetBIOSName `
        -DomainMode "WinThreshold" `
        -ForestMode "WinThreshold" `
        -SafeModeAdministratorPassword $SafeModePass `
        -InstallDns `
        -Force `
        -NoRebootOnCompletion:$false

    Write-Log "Domain Controller promotion initiated. Server restarting..."
} catch {
    Write-Log "Promotion error: $($_.Exception.Message)" "ERROR"
    exit 1
}
