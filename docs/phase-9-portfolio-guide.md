# Phase 9 — Portfolio, GitHub Wiki and Interview Preparation
# Harrington Capital plc | Infrastructure Engineer Simulation

---

## Objective

Polish your GitHub repository into a portfolio-ready evidence pack.
Write STAR interview answers using your own simulation data.
Any hiring manager should be able to open your repo and see a
mid-level infrastructure engineer who can do the job.

---

## BUILD

### Task A — Update the Repository README

Replace the placeholder README with a polished, portfolio-quality version.

Your README must include:

1. **Project summary** (3 sentences — what Harrington Capital is, what you did, what you built)
2. **Repository structure** (table of all folders and what they contain)
3. **Technologies used** (badges or list — Terraform, Azure, PowerShell, Ansible, Docker, Prometheus, Grafana)
4. **What you built** (numbered list of deliverables with GitHub links to the actual files)
5. **Evidence** (links to key screenshots or exported outputs in `/screenshots` and `/evidence`)
6. **Skills demonstrated** (bullet list using employer language from the Skills Blueprint)

Format: professional, concise, no filler.

```bash
git add README.md
git commit -m "docs: portfolio README - Phase 9 complete"
git push origin main
```

### Task B — GitHub Wiki

Enable the GitHub Wiki on your repository:
- Settings → scroll to Features → tick Wikis

Create the following wiki pages:

**Home page:**
- Simulation overview, phase list with links, skills summary

**Infrastructure Overview page:**
- Network topology description, server inventory table, naming standards

**Runbooks Index page:**
- Table linking to all runbooks in `/runbooks/`

**Incident Log page:**
- Table of all incidents worked with GLPI ticket numbers and RCA links

```
| Incident | Date | Priority | Resolution | RCA |
|----------|------|----------|------------|-----|
| INC-20260602-001 | 2026-06-02 | P1 | Disk freed - Docker prune | Link |
```

### Task C — Commit all remaining evidence

Ensure these are in the repo:

```bash
# Screenshots folder (upload Phase 0-8 evidence screenshots)
ls screenshots/

# Evidence folder
ls evidence/

# Confirm all phases have at least one file
for dir in terraform powershell ansible docker monitoring runbooks incident-reports architecture; do
    count=$(find $dir -type f | wc -l)
    echo "$dir: $count files"
done
```

Every folder must have at least one real file (not just .gitkeep).

### Task D — Final commit

```bash
git add .
git commit -m "chore: final portfolio commit - all phases complete - Phase 9"
git push origin main
git log --oneline -15
```

Copy the final 15 commits — paste into your submission.
This shows the full story of what you built.

---

## STAR Interview Answers

Write three STAR-format answers using your own simulation data.
These go in `/evidence/phase-9-star-answers.md`.

**Rules:**
- Use specific numbers from your simulation (not generic statements)
- Reference real tool names and real outputs
- Keep each answer to 200–350 words
- Use the exact STAR structure: Situation → Task → Action → Result

---

### Q1 — Infrastructure Problem Identification

**"Tell me about a time you identified and resolved a critical infrastructure problem."**

Write your answer using:
- **Situation:** HC-APP01 disk at 97%, application returning 500 errors, Finance team impacted
- **Task:** P1 incident triage — identify root cause and restore service within SLA (4 hours)
- **Action:** `df -h` revealed root cause was Docker build cache accumulation (~8.2 GB); `docker system prune` freed disk; verified with `curl /health`
- **Result:** Service restored in 1h 33m (within P1 SLA); RCA filed (INC-20260602-001); Grafana alert configured at 75% threshold preventing recurrence

**Your answer must cite:** disk percentage, resolution time, ticket number.

---

### Q2 — Stakeholder Communication Under Pressure

**"Describe a situation where you had to communicate a technical issue to a senior stakeholder."**

Write your answer using:
- **Situation:** DORA compliance gap identified — DR test 14 months overdue, no infrastructure IaC, monitoring gaps
- **Task:** Prepare executive infrastructure summary for CTO (Sophie Cartwright) — 1-page, no jargon
- **Action:** Structured report using RAG status, completed remediation table, outstanding actions with owners and dates
- **Result:** CTO signed off on remediation plan; DORA obligations now evidenced for Article 11 and Article 26

**Your answer must cite:** DORA article numbers, specific remediation items from your exec report.

---

### Q3 — Automation and Efficiency

**"Give me an example of how you automated a manual process to save time."**

Write your answer using:
- **Situation:** User provisioning was a manual process — AD account creation done field by field in dsa.msc
- **Task:** Build a reusable PowerShell script that provisions users from a CSV with OU assignment and logging
- **Action:** Built `04-user-provisioning.ps1` — reads CSV, maps department to OU, creates accounts, logs output; tested with 3 users, confirmed `Created: 3, Failed: 0`
- **Result:** Provisioning a batch of 10 users reduced from ~45 minutes manual to under 2 minutes; script committed and runbook filed for team reuse

**Your answer must cite:** script filename, user count, time comparison.

---

## VERIFY

```bash
# All folders populated
for dir in terraform powershell ansible docker monitoring runbooks incident-reports architecture screenshots evidence; do
    count=$(find $dir -type f ! -name ".gitkeep" | wc -l)
    echo "$dir: $count files"
done

# Final commit log
git log --oneline -15

# Repo is public
curl -s https://api.github.com/repos/YOUR-USERNAME/harrington-infrastructure-operations | python3 -c "import sys,json; d=json.load(sys.stdin); print('Public:', not d['private'])"
```

---

## SUBMIT

| # | Evidence | How to get it |
|---|----------|---------------|
| 1 | GitHub repository URL | Public URL of your repo |
| 2 | Final `git log --oneline -15` | Terminal output |
| 3 | GitHub Wiki URL | Link to your Wiki Home page |
| 4 | STAR answers GitHub URL | `/evidence/phase-9-star-answers.md` |
| 5 | README screenshot | Screenshot of your polished README on GitHub |

**Anti-fake check:** `git log` must show commits across multiple dates
(spanning your working period) and reference real phase work.
A repo with one bulk commit from one day is not accepted.
