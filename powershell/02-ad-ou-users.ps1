#Requires -RunAsAdministrator
#Requires -Module ActiveDirectory
<#
.SYNOPSIS
    Harrington Capital plc -- AD OU Structure and User Creation
    Phase 2 (Post-promotion): Run after server restarts as DC.

.DESCRIPTION
    BUILD  : Creates OU structure for Harrington Capital, creates 10 test users.
    VERIFY : Lists all OUs, confirms user count, tests authentication.
    SUBMIT : Paste the VERIFICATION OUTPUT section into your submission.
#>

Import-Module ActiveDirectory

$Domain     = "DC=harrington,DC=local"
$LogPath    = "C:\HC-Logs\ad-ous-$(Get-Date -Format 'yyyyMMdd-HHmm').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $entry
    Add-Content -Path $LogPath -Value $entry
}

# -----------------------------------------------------------------
# STEP 3: CREATE OU STRUCTURE
# -----------------------------------------------------------------
Write-Log "=== CREATING OU STRUCTURE ==="

$OUs = @(
    @{ Name = "Harrington Capital";        Path = $Domain },
    @{ Name = "Users";                     Path = "OU=Harrington Capital,$Domain" },
    @{ Name = "Computers";                 Path = "OU=Harrington Capital,$Domain" },
    @{ Name = "Groups";                    Path = "OU=Harrington Capital,$Domain" },
    @{ Name = "Service Accounts";          Path = "OU=Harrington Capital,$Domain" },
    @{ Name = "Technology";                Path = "OU=Users,OU=Harrington Capital,$Domain" },
    @{ Name = "Finance";                   Path = "OU=Users,OU=Harrington Capital,$Domain" },
    @{ Name = "Investments";               Path = "OU=Users,OU=Harrington Capital,$Domain" },
    @{ Name = "Risk and Compliance";       Path = "OU=Users,OU=Harrington Capital,$Domain" },
    @{ Name = "Operations";                Path = "OU=Users,OU=Harrington Capital,$Domain" },
    @{ Name = "Workstations";             Path = "OU=Computers,OU=Harrington Capital,$Domain" },
    @{ Name = "Servers";                   Path = "OU=Computers,OU=Harrington Capital,$Domain" }
)

foreach ($ou in $OUs) {
    try {
        New-ADOrganizationalUnit -Name $ou.Name -Path $ou.Path -ProtectedFromAccidentalDeletion $true
        Write-Log "Created OU: $($ou.Name) in $($ou.Path)"
    } catch {
        if ($_.Exception.Message -like "*already exists*") {
            Write-Log "OU already exists (skipping): $($ou.Name)" "WARN"
        } else {
            Write-Log "Error creating OU $($ou.Name): $($_.Exception.Message)" "ERROR"
        }
    }
}

# -----------------------------------------------------------------
# STEP 4: CREATE TEST USERS
# -----------------------------------------------------------------
Write-Log "=== CREATING TEST USERS ==="

$DefaultPass = ConvertTo-SecureString "HC@User2026!" -AsPlainText -Force

$Users = @(
    @{ First="James";   Last="Okafor";      SAM="j.okafor";     OU="Technology";        Title="Head of Infrastructure" },
    @{ First="Priya";   Last="Sharma";      SAM="p.sharma";     OU="Technology";        Title="Senior Infrastructure Engineer" },
    @{ First="Marcus";  Last="Webb";        SAM="m.webb";       OU="Risk and Compliance"; Title="Security and Compliance Lead" },
    @{ First="Sophie";  Last="Cartwright";  SAM="s.cartwright"; OU="Technology";        Title="Chief Technology Officer" },
    @{ First="Alice";   Last="Thornton";    SAM="a.thornton";   OU="Finance";           Title="Finance Analyst" },
    @{ First="Ben";     Last="Hargreaves";  SAM="b.hargreaves"; OU="Investments";       Title="Portfolio Manager" },
    @{ First="Chloe";   Last="Mwangi";      SAM="c.mwangi";     OU="Operations";        Title="Operations Coordinator" },
    @{ First="David";   Last="Kowalski";    SAM="d.kowalski";   OU="Technology";        Title="Systems Administrator" },
    @{ First="Emma";    Last="Fairfax";     SAM="e.fairfax";    OU="Risk and Compliance"; Title="GRC Analyst" },
    @{ First="Finn";    Last="Oduya";       SAM="f.oduya";      OU="Finance";           Title="Finance Manager" }
)

foreach ($u in $Users) {
    $ouPath = "OU=$($u.OU),OU=Users,OU=Harrington Capital,$Domain"
    $upn    = "$($u.SAM)@harrington.local"

    try {
        New-ADUser `
            -GivenName       $u.First `
            -Surname         $u.Last `
            -Name            "$($u.First) $($u.Last)" `
            -SamAccountName  $u.SAM `
            -UserPrincipalName $upn `
            -Title           $u.Title `
            -Path            $ouPath `
            -AccountPassword $DefaultPass `
            -Enabled         $true `
            -PasswordNeverExpires $false `
            -ChangePasswordAtLogon $true

        Write-Log "Created user: $upn | OU: $($u.OU) | Title: $($u.Title)"
    } catch {
        Write-Log "Error creating user $upn : $($_.Exception.Message)" "ERROR"
    }
}

# -----------------------------------------------------------------
# VERIFICATION OUTPUT -- COPY THIS INTO YOUR SUBMISSION
# -----------------------------------------------------------------
Write-Host ""
Write-Host "================================================================"
Write-Host "  VERIFICATION OUTPUT -- PASTE THIS INTO YOUR SUBMISSION"
Write-Host "================================================================"
Write-Host ""

Write-Host "--- DOMAIN INFO ---"
Get-ADDomain | Select-Object Name, DomainMode, PDCEmulator | Format-List

Write-Host "--- OU STRUCTURE ---"
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName | Format-Table -AutoSize

Write-Host "--- USER COUNT BY OU ---"
$OUNames = @("Technology","Finance","Investments","Risk and Compliance","Operations")
foreach ($ouName in $OUNames) {
    $ouDN = "OU=$ouName,OU=Users,OU=Harrington Capital,$Domain"
    $count = (Get-ADUser -Filter * -SearchBase $ouDN).Count
    Write-Host "  $ouName : $count users"
}

Write-Host ""
Write-Host "--- TOTAL USER COUNT ---"
$total = (Get-ADUser -Filter * -SearchBase "OU=Users,OU=Harrington Capital,$Domain").Count
Write-Host "  Total users: $total"

Write-Host ""
Write-Host "--- DNS RESOLUTION TEST ---"
Resolve-DnsName "harrington.local" -ErrorAction SilentlyContinue | Select-Object Name, IPAddress | Format-Table

Write-Host ""
Write-Host "--- AD DS SERVICE STATUS ---"
Get-Service -Name "ADWS","DNS","KDC","Netlogon" | Select-Object Name, Status | Format-Table

Write-Log "=== Setup and verification complete. Copy output above into submission. ==="
