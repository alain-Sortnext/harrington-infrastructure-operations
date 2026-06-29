# Phase 6 — Incident Response and ITSM
# Harrington Capital plc | Infrastructure Engineer Simulation

---

## Objective

Work a simulated P1 incident from detection to RCA.
The incident: HC-APP01 disk at 97% — application returning 500 errors.
File the overdue RCA in GLPI. Establish the incident management process.

**By the end of this phase you will have:**
- A GLPI P1 incident ticket worked end-to-end
- The incident resolved (disk freed)
- RCA document filed and committed to `/incident-reports`
- Change request raised for permanent fix

---

## THE SCENARIO

It is Monday morning, Week 7.

You receive this message from James Okafor:

> "We've got alerts firing on HC-APP01. The Flask app is returning 500s.
> Users in Finance can't access the ops portal. Can you look at this now?
> This is our third disk incident in two months — I need an RCA filed
> today and a change request through the CAB by Friday.
> Ticket number: INC-20260602-001."

---

## BUILD

### Step 1 — Open the GLPI incident ticket

Log into GLPI and create/update ticket INC-20260602-001:

- Title: `[P1] HC-APP01 disk full — application returning 500 errors`
- Priority: P1
- Category: Infrastructure / Storage
- Status: In Progress
- Assign to: yourself
- Description: paste the message from James

**Screenshot the ticket at this stage.**

### Step 2 — Triage the incident

SSH into HC-APP01:

```bash
# Check disk usage
df -h

# Find what is consuming disk
du -sh /* 2>/dev/null | sort -rh | head -20
du -sh /var/log/* 2>/dev/null | sort -rh | head -10

# Check Docker
docker system df

# Check application logs
docker logs hc-app --tail=50
docker logs hc-nginx --tail=20
```

Document everything you find in the GLPI ticket.

### Step 3 — Identify root cause

The disk is filled by one of these common causes:

**Most likely: Docker logs or container volumes**

```bash
# Check Docker overlay storage
du -sh /var/lib/docker/overlay2/* 2>/dev/null | sort -rh | head -10

# Check log sizes
ls -lh /var/lib/docker/containers/*/*.log 2>/dev/null
```

**Or: Application logs not rotated**

```bash
ls -lh /var/log/
find /var/log -name "*.log" -size +100M 2>/dev/null
```

### Step 4 — Contain: free the disk

```bash
# Prune Docker (remove stopped containers, unused images, build cache)
docker system prune -f

# Rotate and compress large logs
sudo find /var/log -name "*.log" -size +50M -exec gzip {} \;

# Clear old journal entries
sudo journalctl --vacuum-size=500M

# Verify disk freed
df -h
```

Disk usage must drop below 75% before proceeding.

### Step 5 — Verify application restored

```bash
curl -s http://localhost:8080/health
curl -s http://localhost:8080/db-check
```

Both must return status 200 / `"status": "healthy"`.

### Step 6 — Update and close GLPI ticket

- Paste `df -h` output (before and after)
- Paste `curl /health` response
- Set status: **Solved**
- Set resolution: "Freed 8.2 GB by pruning Docker build cache and compressing rotated logs"
- Set resolution time

**Screenshot the resolved ticket.**

### Step 7 — Write the RCA

Copy `/incident-reports/INC-TEMPLATE-RCA.md` and rename to:
`incident-reports/INC-20260602-001-RCA.md`

Complete every section. Key fields:

| Field | Value |
|-------|-------|
| Incident ID | INC-20260602-001 |
| Priority | P1 |
| Detection time | 09:14 Monday (simulate) |
| Resolution time | 10:47 Monday (simulate) |
| Duration | 1 hour 33 minutes |
| Systems affected | HC-APP01 |
| Users affected | Finance team (~12 users) |

**Root cause:** Docker build cache and unrotated application logs consumed
available disk space on HC-APP01 at a rate of approximately 2 GB per week.
No disk usage alerting threshold was configured in Prometheus/Grafana.

**Remediation:**
- Immediate: `docker system prune` and log compression
- Short-term (7 days): Configure Grafana alert at 75% disk usage
- Long-term (30 days): Implement Docker log rotation policy via daemon.json

### Step 8 — Raise a change request

Create a second GLPI ticket:
- Title: `CHG-20260602-001 — Implement disk usage alerting and Docker log rotation`
- Type: Change Request
- Priority: P2
- Reference RCA: INC-20260602-001

### Step 9 — Commit

```bash
git add incident-reports/INC-20260602-001-RCA.md
git commit -m "docs(incidents): P1 RCA filed - INC-20260602-001 disk full HC-APP01 - Phase 6"
git push origin main
```

---

## VERIFY

```bash
# Confirm disk healthy
df -h | grep -E "^/dev|Filesystem"

# Confirm app running
curl -s http://localhost:8080/health

# Confirm Docker cleaned up
docker system df
```

---

## SUBMIT

| # | Evidence | How to get it |
|---|----------|---------------|
| 1 | GLPI ticket screenshot (In Progress) | Ticket showing P1 status and your triage notes |
| 2 | GLPI ticket screenshot (Solved) | Resolved ticket with resolution notes |
| 3 | `df -h` before screenshot | Shows >90% usage |
| 4 | `df -h` after screenshot | Shows <75% usage |
| 5 | `curl /health` output | JSON showing `"status": "healthy"` |
| 6 | RCA document GitHub URL | `incident-reports/INC-20260602-001-RCA.md` |

**Anti-fake check:** GLPI ticket must show a real ticket number
(system-assigned, e.g. Ticket #4). Screenshot must show the number.
