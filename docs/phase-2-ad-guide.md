# Phase 2 — Active Directory and Windows Server
# Harrington Capital plc | Infrastructure Engineer Simulation

---

## Objective

Build and document Harrington Capital's Active Directory estate on HC-DC01.
The previous engineer (Callum Reid) left no documentation.
You are starting from a bare Windows Server 2022 installation.

**By the end of this phase you will have:**
- AD DS installed and HC-DC01 promoted to Domain Controller
- Domain: `harrington.local`
- Full OU structure documented and built
- 10 user accounts created across departments
- DNS verified and resolving
- Everything documented and committed to GitHub

---

## BUILD

### Step 1 — Install AD DS (run as Administrator on HC-DC01)

Open PowerShell 7 as Administrator and run:

```powershell
cd C:\path\to\harrington-infrastructure-operations\powershell
.\01-ad-setup.ps1
```

This script:
- Installs the AD DS Windows Feature
- Promotes HC-DC01 to Domain Controller for `harrington.local`
- Installs DNS Server role automatically
- **Restarts the server** — this is expected

Wait for the server to restart (approximately 3–5 minutes).

### Step 2 — Create OU Structure and Users (after restart)

Log in to HC-DC01 as `HARRINGTON\Administrator`.

Open PowerShell 7 as Administrator:

```powershell
cd C:\path\to\harrington-infrastructure-operations\powershell
.\02-ad-ou-users.ps1
```

This script:
- Creates the full OU structure under `harrington.local`
- Creates 10 user accounts across 5 departments
- Runs verification and prints output

**Copy the entire VERIFICATION OUTPUT section — you will paste it into your submission.**

### Step 3 — Verify DNS resolution

On HC-DC01, run:

```powershell
Resolve-DnsName "harrington.local"
Resolve-DnsName "HC-DC01.harrington.local"
nslookup harrington.local
```

On another VM (HC-APP01), set DNS to point to HC-DC01's IP, then:

```bash
nslookup harrington.local <HC-DC01-IP>
dig harrington.local @<HC-DC01-IP>
```

### Step 4 — Take verification screenshots

Open **Active Directory Users and Computers** (dsa.msc):
- Expand `harrington.local`
- Expand the full OU tree
- Screenshot showing all OUs visible

Open **DNS Manager** (dnsmgmt.msc):
- Expand Forward Lookup Zones
- Screenshot showing `harrington.local` zone

### Step 5 — Document the OU structure

Open `/architecture/hc-ad-structure.drawio` (create it in Draw.io).

Draw the OU hierarchy:

```
harrington.local
└── Harrington Capital (OU)
    ├── Users (OU)
    │   ├── Technology
    │   ├── Finance
    │   ├── Investments
    │   ├── Risk and Compliance
    │   └── Operations
    ├── Computers (OU)
    │   ├── Workstations
    │   └── Servers
    ├── Groups (OU)
    └── Service Accounts (OU)
```

Export as PNG. Commit both files.

### Step 6 — Commit your scripts and diagram

```bash
git add architecture/hc-ad-structure.drawio architecture/hc-ad-structure.png
git commit -m "docs(architecture): AD OU structure diagram - Phase 2"
git push origin main
```

---

## VERIFY

Run these PowerShell checks on HC-DC01 and copy the output:

```powershell
# Domain info
Get-ADDomain | Select-Object Name, DomainMode, PDCEmulator

# All OUs
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName | Format-Table -AutoSize

# User count by department
$base = "OU=Users,OU=Harrington Capital,DC=harrington,DC=local"
foreach ($dept in @("Technology","Finance","Investments","Risk and Compliance","Operations")) {
    $count = (Get-ADUser -Filter * -SearchBase "OU=$dept,$base").Count
    Write-Host "$dept : $count users"
}

# Total users
(Get-ADUser -Filter * -SearchBase $base).Count

# DNS test
Resolve-DnsName "harrington.local"

# Services running
Get-Service ADWS, DNS, KDC, Netlogon | Select-Object Name, Status
```

All services must show `Running`. Total users must be **10**.

---

## SUBMIT

Your Phase 2 submission must include:

| # | Evidence | How to get it |
|---|----------|---------------|
| 1 | PowerShell VERIFICATION OUTPUT | Copy from script output after running `02-ad-ou-users.ps1` |
| 2 | AD Users and Computers screenshot | dsa.msc — full OU tree visible |
| 3 | DNS Manager screenshot | dnsmgmt.msc — harrington.local zone |
| 4 | OU structure diagram | `/architecture/hc-ad-structure.png` |
| 5 | GitHub commit URL | Commit adding diagram to repo |

**Anti-fake check:** Your submission must include a user count per OU.
The correct counts are: Technology 4, Finance 2, Investments 1, Risk and Compliance 2, Operations 1.

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Install-ADDSForest: The specified domain already exists` | Domain was already created — skip to Step 2 |
| `Access denied` | Ensure PowerShell is running as Administrator |
| `Cannot connect to domain` | Check HC-DC01 IP and firewall — port 389 (LDAP) must be open |
| DNS not resolving from HC-APP01 | Set HC-APP01 DNS to HC-DC01 IP: `sudo nano /etc/resolv.conf` |
| Users not visible in dsa.msc | Close and reopen Active Directory Users and Computers |
