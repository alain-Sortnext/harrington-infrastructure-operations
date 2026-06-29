# RB-INCIDENT-RESPONSE-v1
# Harrington Capital plc -- Runbook
# P1/P2 Incident Response Procedure

---

**Runbook ID:** RB-INCIDENT-RESPONSE-v1
**Version:** 1.0
**Owner:** Infrastructure Operations
**Last updated:** 2026-06-01
**Review due:** 2026-12-01
**Regulatory ref:** DORA Article 17 -- ICT-related incident management

---

## Purpose

Standard procedure for declaring, triaging, resolving, and closing
Priority 1 and Priority 2 incidents affecting the Harrington Capital
infrastructure estate.

---

## Incident Priority Definitions

| Priority | Description | Response SLA | Resolution SLA |
|----------|-------------|-------------|----------------|
| P1 | Complete outage or data loss risk | 15 minutes | 4 hours |
| P2 | Significant degradation | 30 minutes | 8 hours |
| P3 | Minor issue | 2 hours | Next business day |
| P4 | Cosmetic / low impact | 4 hours | Within 5 days |

---

## P1 Response Procedure

### Step 1 -- Declare incident (within 15 minutes of detection)

Open GLPI ticket immediately:
- Category: Incident
- Sub-category: Infrastructure
- Priority: P1
- Title format: [P1] Brief description - YYYY-MM-DD
- Assign to: Infrastructure Operations queue
- Note the ticket number: INC-YYYYMMDD-NNN

Notify Head of Infrastructure (James Okafor):
- Phone first
- Follow with Slack/Teams message including ticket number

### Step 2 -- Initial triage

Document in ticket:
- Time of detection
- Systems affected
- Business impact (what cannot users / systems do?)
- First symptoms observed

Run initial diagnostics:

```powershell
# Check server status
Get-Service -ComputerName HC-DC01, HC-APP01, HC-MON01 | Where-Object Status -ne Running

# Check disk space (common P1 cause)
.\powershell\03-disk-health-check.ps1

# Check event logs
Get-EventLog -LogName System -Newest 20 -EntryType Error -ComputerName HC-DC01
```

For Linux hosts:

```bash
# Check services
sudo systemctl status --failed

# Check disk
df -h

# Check recent errors
sudo journalctl -p err -n 50 --since "1 hour ago"
```

### Step 3 -- Contain and restore

Apply fix appropriate to the incident type.
Document every action taken in the GLPI ticket with timestamps.

### Step 4 -- Verify resolution

Confirm with affected users or systems that service is restored.
Run validation checks and paste output into ticket.

### Step 5 -- Close ticket

Set ticket status: Solved.
Set resolution time.
Notify stakeholders.

### Step 6 -- Post-incident (within 48 hours)

File Root Cause Analysis using template:
/incident-reports/INC-TEMPLATE-RCA.md

Submit RCA to Change Advisory Board via CHG ticket.
Reference DORA Article 17 in the CHG ticket description.

---

## Escalation Matrix

| Situation | Escalate to |
|-----------|-------------|
| DC01 unreachable | Priya Sharma (Senior Infra) |
| Data loss suspected | Marcus Webb (Security) + James Okafor |
| > 2 hour unresolved P1 | Sophie Cartwright (CTO) |
| Regulatory notification trigger | Marcus Webb (Compliance) |

---

## DORA Notification Thresholds

Per DORA Article 17, major incidents must be notified to the FCA.
Contact Marcus Webb immediately if:
- Incident affects core trading or settlement systems
- Incident lasts more than 4 hours
- Incident affects more than 10% of users
- Data confidentiality has been compromised
