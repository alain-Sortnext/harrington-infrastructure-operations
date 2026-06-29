# Phase 7 — Automation Suite and Runbooks
# Harrington Capital plc | Infrastructure Engineer Simulation

---

## Objective

Build the automation suite that prevents repeat incidents and saves
the team hours of manual work every week. Scripts run. Output captured.
Runbooks filed. Everything committed.

**By the end of this phase you will have:**
- PowerShell disk health monitor running and producing output
- PowerShell bulk user provisioning script tested with real CSV
- Ansible patch baseline applied to all Linux hosts
- Two runbooks committed to `/runbooks`

---

## BUILD

### Task A — PowerShell Disk Health Monitor

#### Build

On HC-DC01, run:

```powershell
cd C:\path\to\harrington-infrastructure-operations\powershell
.\03-disk-health-check.ps1
```

The script checks all servers in its `$Servers` array and reports:
- Drive, total GB, used GB, free GB, used %, status (OK / WARNING / CRITICAL)

#### Verify

Output must show:
- At least 3 servers checked
- Status column (OK, WARNING, or CRITICAL)
- Log file written to `C:\HC-Logs\`

#### Submit

Paste the `DISK HEALTH SUMMARY` table from the console output.

---

### Task B — PowerShell Bulk User Provisioning

#### Build

First, create a CSV file of new starters.
Copy the template from `/evidence/new-starter-template.csv` and add 3 test users.

Example content:

```csv
FirstName,LastName,Department,Title,Manager
Test,User1,Technology,Junior Engineer,j.okafor
Test,User2,Finance,Finance Analyst,f.oduya
Test,User3,Operations,Operations Assistant,c.mwangi
```

Save as `C:\HC-Logs\new-starters.csv` on HC-DC01.

Run the provisioning script:

```powershell
.\04-user-provisioning.ps1 -CsvPath "C:\HC-Logs\new-starters.csv"
```

#### Verify

```powershell
# Confirm users were created
Get-ADUser -Filter "Name -like 'Test*'" | Select-Object Name, SamAccountName, Enabled

# Clean up test users after verification
Get-ADUser -Filter "Name -like 'Test*'" | Remove-ADUser -Confirm:$false
```

#### Submit

Paste the `PROVISIONING SUMMARY` from the console output.
Include the count: `Created: 3 | Failed: 0`.

---

### Task C — Ansible Patch Baseline

#### Build

On your Ansible control machine:

```bash
cd harrington-infrastructure-operations/ansible
ansible-playbook -i inventory.ini patch-baseline.yml
```

This patches all Linux hosts one at a time (serial: 1) to reduce blast radius.

#### Verify

```bash
# Check patch log on HC-APP01
ssh hcadmin@<HC-APP01-IP> "cat /var/log/hc-patch-log.txt"

# Confirm no pending security updates
ssh hcadmin@<HC-APP01-IP> "apt list --upgradable 2>/dev/null | grep -c security"
# Should be 0
```

#### Submit

- Full Ansible PLAY RECAP
- Contents of `/var/log/hc-patch-log.txt` from each host

---

### Task D — Grafana Disk Alert Rule

Add an alert to Grafana that fires when disk usage exceeds 75%:

1. Open Grafana → Alerting → Alert rules → New alert rule
2. Name: `HC Disk Usage Warning`
3. Query:

```promql
100 - ((node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100) > 75
```

4. Condition: IS ABOVE 75
5. Evaluation: every 1m for 5m
6. Save

**Screenshot the alert rule configuration.**

---

### Task E — Verify Runbooks

The runbooks already exist in `/runbooks/`. Your task is to:

1. Read both runbooks end-to-end.
2. Follow RB-USER-PROVISIONING-v1 for your Task B above — document that you followed it.
3. Add a brief entry at the bottom of each runbook confirming it was tested:

```markdown
---
## Test Record
Date: 2026-06-09
Tested by: [Your name]
Result: PASS
Notes: All steps completed successfully. Script produced correct output.
```

Commit the updated runbooks:

```bash
git add runbooks/
git commit -m "docs(runbooks): test records added after Phase 7 verification"
git push origin main
```

---

## VERIFY

```bash
# PowerShell scripts ran successfully
ls C:\HC-Logs\disk-check-*.log  # Should exist
ls C:\HC-Logs\user-provisioning-*.log  # Should exist

# Ansible patched successfully
ssh hcadmin@<HC-APP01-IP> "cat /var/log/hc-patch-log.txt"

# Grafana alert exists
curl -s http://admin:admin@localhost:3000/api/v1/provisioning/alert-rules | python3 -m json.tool | grep "HC Disk"
```

---

## SUBMIT

| # | Evidence | How to get it |
|---|----------|---------------|
| 1 | Disk health check output | Console DISK HEALTH SUMMARY table |
| 2 | User provisioning output | Console PROVISIONING SUMMARY (Created: 3, Failed: 0) |
| 3 | Ansible PLAY RECAP | Full recap showing both hosts patched |
| 4 | Grafana alert rule screenshot | Alert rule configuration page |
| 5 | Runbook GitHub URLs | Both runbooks with test records committed |

**Anti-fake check:** Disk health log file must exist at `C:\HC-Logs\` with today's date in the filename. Ansible log must show real timestamps on each host.
