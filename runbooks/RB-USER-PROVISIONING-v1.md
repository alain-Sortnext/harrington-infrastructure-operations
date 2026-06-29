# RB-USER-PROVISIONING-v1
# Harrington Capital plc -- Runbook
# User Provisioning and Offboarding

---

**Runbook ID:** RB-USER-PROVISIONING-v1
**Version:** 1.0
**Owner:** Infrastructure Operations
**Last updated:** 2026-06-01
**Review due:** 2026-12-01

---

## Purpose

Standard procedure for provisioning new user accounts and offboarding leavers
in the Harrington Capital Active Directory estate.

---

## Scope

Applies to all new starters and leavers in the harrington.local domain.
Does not cover Azure Entra ID (cloud identity) -- see RB-ENTRA-PROVISIONING-v1.

---

## Prerequisites

- Run on HC-DC01 as Domain Admin
- PowerShell 7.x installed
- Script: /powershell/04-user-provisioning.ps1 in the repository
- CSV template: /evidence/new-starter-template.csv

---

## New Starter Procedure

### Step 1 -- Receive request

Receive new starter details from HR via email or ITSM ticket.
Open a GLPI ticket: Category = User Management / Sub-category = New Starter.
Note the ticket number -- required in Step 5.

### Step 2 -- Prepare CSV

Copy /evidence/new-starter-template.csv and fill in:

| Field      | Value                     |
|------------|---------------------------|
| FirstName  | Employee first name        |
| LastName   | Employee last name         |
| Department | From approved list (below) |
| Title      | Job title from HR system   |
| Manager    | Manager SAM account name   |

Approved department values:
- Technology
- Finance
- Investments
- Risk and Compliance
- Operations

### Step 3 -- Run provisioning script

On HC-DC01:

```powershell
cd C:\harrington-infrastructure-operations\powershell
.\04-user-provisioning.ps1 -CsvPath "C:\HC-Logs\new-starters.csv"
```

### Step 4 -- Verify output

Confirm:
- Created count matches expected
- Failed count is 0
- UPNs follow format: firstname.lastname@harrington.local

### Step 5 -- Update ITSM ticket

Paste the VERIFICATION OUTPUT into the GLPI ticket.
Set ticket status: Resolved.
Assign to requestor.

### Step 6 -- Communicate credentials

Send welcome email to line manager with:
- Username (UPN)
- Temporary password: HC@NewStarter2026!
- Password change required on first login
- IT support contact: it-support@harrington.co.uk

---

## Leaver Procedure

### Step 1 -- Receive offboarding request

Receive from HR with last working day confirmed.
Open GLPI ticket: Category = User Management / Sub-category = Leaver.

### Step 2 -- On last working day (end of business)

Disable the account:

```powershell
Disable-ADAccount -Identity "firstname.lastname"
```

Move to disabled OU:

```powershell
Move-ADObject -Identity (Get-ADUser "firstname.lastname").DistinguishedName `
    -TargetPath "OU=Disabled,OU=Harrington Capital,DC=harrington,DC=local"
```

Reset password:

```powershell
Set-ADAccountPassword -Identity "firstname.lastname" `
    -NewPassword (ConvertTo-SecureString "$(New-Guid)" -AsPlainText -Force)
```

### Step 3 -- Verify

```powershell
Get-ADUser -Identity "firstname.lastname" | Select-Object Enabled, DistinguishedName
```

Confirm Enabled = False.

### Step 4 -- Schedule deletion

Account held for 90 days per data retention policy.
Create a calendar reminder for deletion date.
After 90 days: Remove-ADUser.

### Step 5 -- Update ITSM ticket

Paste PowerShell output.
Set status: Resolved.

---

## Escalation

If script fails or account cannot be located:
- Escalate to Senior Infrastructure Engineer (Priya Sharma)
- If domain controller unreachable: follow RB-DR-v1

---

## Audit

All provisioning actions are logged at:
C:\HC-Logs\user-provisioning-YYYYMMDD-HHmm.log

Logs retained for 12 months per ISO 27001 A.12.4.1.
