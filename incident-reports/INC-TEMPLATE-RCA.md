# INC-TEMPLATE-RCA
# Harrington Capital plc -- Root Cause Analysis Template
# Copy and rename to: INC-YYYYMMDD-NNN-RCA.md

---

## Incident Details

| Field | Value |
|-------|-------|
| **Incident ID** | INC-YYYYMMDD-NNN |
| **Priority** | P1 / P2 |
| **Title** | Brief description |
| **Detection time** | YYYY-MM-DD HH:MM |
| **Resolution time** | YYYY-MM-DD HH:MM |
| **Total duration** | X hours Y minutes |
| **Systems affected** | HC-DC01, HC-APP01 etc |
| **Users affected** | Estimated count |
| **Author** | Your name |
| **RCA submitted** | YYYY-MM-DD |
| **Change request ref** | CHG-YYYYMMDD-NNN |

---

## Executive Summary

One paragraph. Describe what happened, the business impact, the root cause,
and the primary remediation action. Written for non-technical readers.

---

## Timeline of Events

| Time | Event |
|------|-------|
| HH:MM | First symptom observed |
| HH:MM | Incident declared / GLPI ticket opened |
| HH:MM | Initial triage complete |
| HH:MM | Root cause identified |
| HH:MM | Fix applied |
| HH:MM | Service restored |
| HH:MM | Incident closed |

---

## Root Cause

### Primary root cause

Describe the specific technical cause. Be precise -- not "disk filled up"
but "trading platform log rotation was disabled, causing /var/log to fill
to 100% on HC-APP01 within 72 hours of a log verbosity increase applied
on YYYY-MM-DD."

### Contributing factors

List any factors that made the incident worse or harder to detect:
- Factor 1
- Factor 2

### Why it was not caught earlier

Describe the monitoring gap, process gap, or configuration gap that
allowed the condition to develop undetected.

---

## Impact Assessment

| Category | Detail |
|----------|--------|
| Service disruption | X minutes of complete outage |
| Users affected | N users could not access [system] |
| Financial exposure | Estimated £X (if applicable) |
| Data integrity | Confirmed not affected / affected (explain) |
| Regulatory trigger | Yes / No -- if yes, state DORA article |

---

## Remediation Actions

### Immediate (applied during incident)

1. Action taken
2. Action taken

### Short-term (within 7 days)

1. Action | Owner | Due date
2. Action | Owner | Due date

### Long-term (within 30 days)

1. Action | Owner | Due date
2. Action | Owner | Due date

---

## Lessons Learned

What went well:

- Item 1
- Item 2

What could be improved:

- Item 1
- Item 2

---

## Sign-off

| Role | Name | Date |
|------|------|------|
| Author | | |
| Head of Infrastructure | James Okafor | |
| Security & Compliance | Marcus Webb | |
