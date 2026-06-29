# Phase 8 — Disaster Recovery Test and Executive Report
# Harrington Capital plc | Infrastructure Engineer Simulation

---

## Objective

Execute and document a DORA-compliant DR test.
Verify backup restore integrity.
Write the executive infrastructure summary for Sophie Cartwright (CTO).

**DORA Article 11 and Article 26 require annual DR testing with documented evidence.
The last test was 14 months ago. This is overdue.**

**By the end of this phase you will have:**
- A backup created and restored — with evidence
- DR runbook committed to `/runbooks`
- Executive report (1 page) committed to `/evidence`
- All evidence uploaded and committed

---

## BUILD

### Task A — Create and Restore a Backup

#### Step 1 — Create a backup of HC-APP01 data

On HC-APP01:

```bash
# Create backup directory
sudo mkdir -p /var/backups/harrington

# Backup the Docker volumes
docker compose -f ~/harrington-infrastructure-operations/docker/docker-compose.yml down

# Export the database
docker run --rm \
    -v hc-db-data:/data \
    -v /var/backups/harrington:/backup \
    ubuntu \
    tar czf /backup/hc-db-$(date +%Y%m%d-%H%M).tar.gz -C /data .

# Record the backup file
ls -lh /var/backups/harrington/
```

Bring the stack back up:

```bash
docker compose -f ~/harrington-infrastructure-operations/docker/docker-compose.yml up -d
```

#### Step 2 — Simulate a failure

```bash
# Stop the database container to simulate failure
docker stop hc-db
docker rm hc-db

# Verify the app is returning errors (as expected)
curl -s http://localhost:8080/db-check
# Expected: error response
```

Take a screenshot showing the failed state.

#### Step 3 — Restore from backup

```bash
# Create a new empty volume
docker volume create hc-db-data-restored

# Restore the backup
BACKUP_FILE=$(ls /var/backups/harrington/hc-db-*.tar.gz | tail -1)
docker run --rm \
    -v hc-db-data-restored:/data \
    -v /var/backups/harrington:/backup \
    ubuntu \
    tar xzf /backup/$(basename $BACKUP_FILE) -C /data

echo "Restored from: $BACKUP_FILE"

# Update docker-compose to use restored volume and bring stack up
docker compose -f ~/harrington-infrastructure-operations/docker/docker-compose.yml up -d
```

#### Step 4 — Verify restoration

```bash
curl -s http://localhost:8080/health
curl -s http://localhost:8080/db-check
```

Both must return healthy responses.

```bash
df -h
docker ps
```

**Document the Recovery Time: time from `docker stop` to application healthy again.**

---

### Task B — Complete the DR Runbook

Copy `/runbooks/RB-DR-v1.md` and complete all sections with your actual findings.

Key metrics to record:

| Metric | Your Value |
|--------|-----------|
| Backup size | e.g. 142 MB |
| Backup creation time | e.g. 47 seconds |
| Restore time | e.g. 2 minutes 18 seconds |
| RTO achieved | e.g. 8 minutes total |
| RPO (data age) | e.g. same-day backup |

---

### Task C — Executive Report (1 page)

Write the executive infrastructure summary for Sophie Cartwright (CTO).

Save as `/evidence/phase-8-exec-report.md`.

**Format rules:**
- Maximum 1 page (400 words)
- No jargon
- No tool names unless essential
- Risk status: what was bad, what is now fixed
- Numbers only — no vague statements

**Required sections:**

```
HARRINGTON CAPITAL — INFRASTRUCTURE STATUS REPORT
Date: [today]
Prepared by: [your name]
Recipient: Sophie Cartwright, CTO

EXECUTIVE SUMMARY (3 sentences max)
What the situation was, what you did, what the risk status is now.

COMPLETED REMEDIATION (table)
Item | Previous State | Current State | DORA Obligation Met?
Infrastructure IaC | Manual portal only | Terraform committed | —
AD documentation | None | OU structure documented, 10 accounts | —
Monitoring | 11 hosts not covered | All hosts in Prometheus/Grafana | Art. 17
Incident process | No formal RCA filed | GLPI operational, RCA filed | Art. 17
DR test | 14 months overdue | Test completed, evidence filed | Art. 11 + Art. 26
Automation | Manual operations | PowerShell + Ansible suite committed | —

CURRENT RISK STATUS (RAG)
Red items: [none / list any]
Amber items: [list outstanding items]
Green items: [list completed]

COST IMPACT
Estimated time saved per month by automation: X hours
Estimated risk reduction: [qualitative]

OUTSTANDING ACTIONS
Item | Owner | Due date
```

---

## VERIFY

```bash
# Backup file exists and has size
ls -lh /var/backups/harrington/

# Application healthy after restore
curl -s http://localhost:8080/health | python3 -m json.tool

# DB check passes
curl -s http://localhost:8080/db-check | python3 -m json.tool
```

---

## SUBMIT

| # | Evidence | How to get it |
|---|----------|---------------|
| 1 | Backup file screenshot | `ls -lh /var/backups/harrington/` showing file with date and size |
| 2 | Failed state screenshot | `curl /db-check` returning error during simulated failure |
| 3 | Restored state screenshot | `curl /health` and `curl /db-check` returning healthy |
| 4 | DR runbook GitHub URL | `/runbooks/RB-DR-v1.md` committed |
| 5 | Executive report GitHub URL | `/evidence/phase-8-exec-report.md` committed |

**Anti-fake check:** Backup filename must contain today's date (YYYYMMDD format).
Restore time must be stated in minutes and seconds — not estimated.
