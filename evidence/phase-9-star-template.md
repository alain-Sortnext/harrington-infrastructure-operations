# Phase 9 — STAR Interview Answers
# Harrington Capital plc Infrastructure Engineer Simulation

---

**Candidate:** [Your name]
**Date completed:** [Date]
**Repository:** https://github.com/YOUR-USERNAME/harrington-infrastructure-operations

---

## Instructions

Complete all three STAR answers using your own simulation data.
- Use specific numbers (disk %, ticket numbers, times, script names)
- Do not use generic statements like "I improved performance"
- Each answer: 200–350 words
- Structure: Situation → Task → Action → Result

---

## Q1 — Critical Infrastructure Problem

**"Tell me about a time you identified and resolved a critical infrastructure problem."**

**Situation:**

[Describe the P1 disk incident on HC-APP01 — what the alert showed, which users were impacted, what James Okafor's message said.]

**Task:**

[Describe your responsibility — P1 triage within 15 minutes, restore service within 4-hour SLA, file RCA.]

**Action:**

[Describe exactly what you ran — df -h output, docker system df, docker system prune, verification commands. Include the exact disk percentage before and after.]

**Result:**

[State: service restored in X hours Y minutes. GLPI ticket INC-20260602-001 resolved. Grafana alert configured at 75% threshold. RCA filed and committed to GitHub.]

---

## Q2 — Stakeholder Communication

**"Describe a situation where you communicated a complex technical issue to a senior stakeholder."**

**Situation:**

[Describe the DORA compliance gap — 14 months since last DR test, no IaC, monitoring gaps — and that the CTO needed a briefing.]

**Task:**

[Your task: write a 1-page executive summary for Sophie Cartwright (CTO) covering infrastructure risk status and remediation completed.]

**Action:**

[Describe how you structured the report — RAG table, DORA articles referenced, completed items vs outstanding, cost impact.]

**Result:**

[CTO signed off remediation plan. DORA Articles 11 and 26 now evidenced. Report committed to /evidence/phase-8-exec-report.md in the infrastructure repository.]

---

## Q3 — Automation and Efficiency

**"Give an example of how you automated a manual process to save time."**

**Situation:**

[Describe the manual AD user provisioning process — creating accounts one-by-one in dsa.msc, no logging, no OU assignment checking.]

**Task:**

[Build a reusable PowerShell automation script that provisions users from a CSV with automatic OU mapping and audit logging.]

**Action:**

[Describe building 04-user-provisioning.ps1 — CSV input, department-to-OU mapping hash table, error handling, log file output. Tested with 3 users: Created: 3, Failed: 0.]

**Result:**

[Provisioning 10 users reduced from approximately 45 minutes manual to under 2 minutes. Script committed to GitHub. Runbook RB-USER-PROVISIONING-v1 filed so any team member can use it.]

---

*Save this file as `/evidence/phase-9-star-answers.md` with your completed answers.*
*Commit to GitHub before final submission.*
