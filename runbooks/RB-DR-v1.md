# RB-DR-v1
# Harrington Capital plc -- Disaster Recovery Runbook
# Phase 8: DR Test and Documentation

---

**Runbook ID:** RB-DR-v1
**Version:** 1.0
**Owner:** Infrastructure Operations
**Last updated:** 2026-06-01
**Review due:** 2026-12-01
**Regulatory ref:** DORA Article 11 (ICT Business Continuity) | Article 26 (Resilience Testing)

---

## Purpose

Define the procedure for executing and documenting Harrington Capital's
annual disaster recovery test, in compliance with DORA Article 11 and Article 26.

Evidence from this test must be retained for 5 years per DORA requirements.

---

## Scope

This runbook covers:
- Docker-hosted application stack on HC-APP01
- Database volume backup and restore
- Service restoration verification

Does not cover: Azure VM recovery, AD DS recovery, network failover.
See RB-AZURE-DR-v1 (to be created) for cloud scope.

---

## Recovery Objectives

| Metric | Target | Achieved (complete after test) |
|--------|--------|-------------------------------|
| RTO (Recovery Time Objective) | 30 minutes | ________ |
| RPO (Recovery Point Objective) | 24 hours | ________ |
| Backup verification frequency | Monthly | ________ |
| Last successful restore test | Today | ________ |

---

## DR Test Procedure

### Step 1 -- Pre-test snapshot

Record current state before simulating failure:

```bash
df -h
docker ps
curl -s http://localhost:8080/health
date +"%Y-%m-%d %H:%M:%S" > /var/backups/harrington/dr-test-start.txt
```

### Step 2 -- Create backup

```bash
sudo mkdir -p /var/backups/harrington

docker compose -f ~/harrington-infrastructure-operations/docker/docker-compose.yml down

docker run --rm \
    -v hc-db-data:/data \
    -v /var/backups/harrington:/backup \
    ubuntu \
    tar czf /backup/hc-db-$(date +%Y%m%d-%H%M).tar.gz -C /data .

ls -lh /var/backups/harrington/
```

Record backup filename and size: ____________________________

### Step 3 -- Simulate failure

```bash
docker stop hc-db
docker rm hc-db
docker volume rm hc-db-data
```

Verify failure state:

```bash
curl -s http://localhost:8080/db-check
# Expected: error response
```

Record failure start time: ____________________________

### Step 4 -- Restore

```bash
docker volume create hc-db-data

BACKUP_FILE=$(ls /var/backups/harrington/hc-db-*.tar.gz | tail -1)
docker run --rm \
    -v hc-db-data:/data \
    -v /var/backups/harrington:/backup \
    ubuntu \
    tar xzf /backup/$(basename $BACKUP_FILE) -C /data

docker compose -f ~/harrington-infrastructure-operations/docker/docker-compose.yml up -d
```

### Step 5 -- Verify restoration

```bash
sleep 30
curl -s http://localhost:8080/health
curl -s http://localhost:8080/db-check
docker ps
```

Record restoration complete time: ____________________________

### Step 6 -- Calculate RTO

RTO = restoration complete time minus failure start time = ________

### Step 7 -- Document results

Complete the Test Record section below and commit this file.

---

## Test Record

| Field | Value |
|-------|-------|
| Test date | |
| Tested by | |
| Backup filename | |
| Backup size | |
| Failure simulated at | |
| Service restored at | |
| RTO achieved | |
| RPO | Same-day backup |
| Result | PASS / FAIL |
| Evidence location | /screenshots/ and /evidence/ |
| DORA obligation | Article 11 + Article 26 -- EVIDENCED |

---

## Escalation

If restore fails after 30 minutes:
1. Escalate to Priya Sharma (Senior Infrastructure)
2. Notify James Okafor (Head of Infrastructure)
3. If data loss suspected: notify Marcus Webb (Security and Compliance) immediately -- DORA Article 17 notification may be required

---

## Evidence Retention

All DR test evidence (this runbook, backup files, screenshots) must be
retained for minimum 5 years per DORA Article 26(8).

Store in: `/evidence/dr-test-YYYYMMDD/`
Also commit to: GitHub repository (permanent record)
