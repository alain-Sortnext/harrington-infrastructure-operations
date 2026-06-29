# Harrington Capital plc — Infrastructure Process Notes
## Handover from Priya Sharma, Senior Infrastructure Engineer
### Last updated: 2026-04-14 | Status: INCOMPLETE — Callum never finished this

---

> **NOTE TO NEW STARTER:**
> I've tried to pull together what I know but honestly Callum held most of this
> in his head. These notes cover what I've been able to reconstruct.
> Stages 1–3 are reasonably complete. After that it gets patchy.
> Ask me if you get stuck — though I'm flat out on the Azure migration.
> — Priya

---

## CONTACTS

| Name | Role | Where to find them |
|------|------|--------------------|
| James Okafor | Head of Infrastructure | Slack: @james.okafor | Teams: jamesokafor@harrington.co.uk |
| Priya Sharma | Senior Infrastructure Engineer (me) | Slack: @priya.sharma |
| Marcus Webb | Security & Compliance | Marcus is strict — always CC him on anything touching FCA or DORA |
| Sophie Cartwright | CTO | You will not talk to her directly. Everything goes through James. |
| Callum Reid | Previous engineer (left) | callum.reid.personal@gmail.com — tried to reach him, no response |

---

## OPEN QUESTIONS (things I couldn't answer)

- [ ] What is the purpose of the three servers I found with no hostname documentation? IPs: 10.0.3.41, 10.0.3.42, 10.0.3.43. Are these still in use? No Prometheus targets configured for any of them.
- [ ] The `nsg-app` rule — Callum added a rule called `allow-legacy-api` on port 8081. No idea what it connects to. CHECK THIS before you touch it.
- [ ] AD OU structure: Callum reorganised it in February. I know he moved the service accounts somewhere but I can't find a `Service Accounts` OU. Either he deleted it or renamed it. CHECK THIS.
- [ ] Backup schedule: I know there's a backup job running but I don't know what it's targeting or where it writes to. There's a scheduled task on HC-DC01 called `HC-NightlyBackup` but I've never looked inside it.
- [ ] The `HC-APP01` disk — this has filled up twice in the last six months. Callum said he knew why but never documented the fix. WATCH THIS.

---

## STAGE 1 — AZURE ENVIRONMENT

### Resource Groups

Two resource groups exist:
- `rg-harrington-prod` — UK South — production
- `rg-harrington-dev` — UK South — dev/test

**How we got here:** Everything was provisioned manually through the portal by Callum.
There is no Terraform. No ARM templates. Nothing. This is one of the first things
James wants fixed — IaC for everything.

### Virtual Network

`vnet-harrington-prod` | Address space: 10.0.0.0/16

Subnets:

| Subnet | CIDR | Purpose |
|--------|------|---------|
| snet-app | 10.0.1.0/24 | Application tier VMs |
| snet-data | 10.0.2.0/24 | Reserved — nothing deployed yet |
| snet-mgmt | 10.0.3.0/24 | Management, DC, monitoring |

### NSGs

`nsg-app` — applied to snet-app:
- Deny SSH (22) inbound from Internet ✅
- Allow HTTPS (443) inbound from VirtualNetwork ✅
- `allow-legacy-api` on port 8081 — NOT DOCUMENTED ⚠️

`nsg-mgmt` — applied to snet-mgmt:
- Allow SSH (22) inbound from management subnet ✅
- Allow RDP (3389) inbound from management subnet ✅

### VMs in Azure

| VM Name | OS | Private IP | Subnet | Purpose |
|---------|----|-----------|--------|---------|
| vm-harrington-prod-dc01 | Windows Server 2022 | 10.0.3.10 | mgmt | Domain Controller |
| vm-harrington-prod-app01 | Ubuntu 22.04 | 10.0.1.10 | app | Application workload |
| vm-harrington-prod-mon01 | Ubuntu 22.04 | 10.0.3.20 | mgmt | Prometheus + Grafana |

Plus three unidentified VMs at 10.0.3.41–43. Not in any documentation. ⚠️

---

## STAGE 2 — ACTIVE DIRECTORY

Domain: `harrington.local`
NetBIOS: `HARRINGTON`
Forest/Domain functional level: Windows Server 2016 (Callum never raised it)
PDC Emulator: HC-DC01

### OU Structure (as best I can tell)

Callum reorganised this in February. What I think exists:

```
harrington.local
└── Harrington Capital (OU) — I think
    ├── Users (OU)
    │   ├── Technology
    │   ├── Finance
    │   ├── Investments
    │   ├── Risk and Compliance  ← NOT DOCUMENTED — might be called "Compliance" now
    │   └── Operations
    ├── Computers (OU)
    │   ├── Workstations
    │   └── Servers             ← CHECK THIS — Callum may have renamed it
    └── [something for service accounts — cannot find it] ⚠️
```

> ⚠️ DEPRECATED? Callum mentioned he was going to merge the service accounts OU
> into a sub-OU under Technology. I never confirmed if he did this.

### DNS

DNS runs on HC-DC01. Forward lookup zone: `harrington.local`
Reverse lookup zone: EXISTS — not sure of the range Callum configured.

One thing I noticed: there's a DNS A record for `monitoring.harrington.local`
pointing to 10.0.3.20. Callum set this up but never told anyone. Useful to know.

### Group Policy Objects

I know these GPOs exist but have never audited them:

- Default Domain Policy (don't touch)
- HC-PasswordPolicy (min 12 chars — Marcus insisted on this after the FCA audit)
- HC-DesktopLockout (15-minute screen lock)
- HC-[something]-Servers ← can't remember the name, Callum set it up

> CHECK THIS: Run `Get-GPO -All` on HC-DC01 to get the full list.

### Admin Accounts

Domain admin: `HARRINGTON\Administrator` — James has the password.
Do NOT use this for day-to-day work. Callum used it for everything. Don't.

Service account for backup: `svc_backup` — should be in... somewhere. NOT DOCUMENTED ⚠️

---

## STAGE 3 — LINUX ESTATE (ON-PREMISES)

### HC-APP01

OS: Ubuntu 22.04.3 LTS
IP: 192.168.56.20 (VirtualBox internal) / 10.0.1.10 (Azure)
SSH: key-based only (I think — Callum said he hardened it but I never verified)
User: hcadmin

**Known issue:** SSH hardening is listed as complete in Callum's personal notes
(found a Notepad file on his desktop before IT wiped it) but I could not
verify `PasswordAuthentication no` in `/etc/ssh/sshd_config` before he left.
The fail2ban service was running last time I checked but `ufw` status was
reportedly `inactive`. CHECK THIS.

Docker is installed and running. The hc-nginx, hc-app, hc-db stack is deployed.
I don't know the current state of the containers since the last disk incident.

### HC-MON01

OS: Ubuntu 22.04.3 LTS
IP: 192.168.56.30 (VirtualBox) / 10.0.3.20 (Azure)
SSH: hcadmin

Prometheus is installed at `/etc/prometheus/prometheus.yml`.
Grafana is installed and running on port 3000.

> ⚠️ The prometheus.yml is out of date. Callum added targets by hand and then
> never kept the file in sync. The CURRENT scrape targets are different from what's
> in the file. Run `curl http://localhost:9090/api/v1/targets` on HC-MON01 to see
> what is actually being scraped vs what the config says.

> ⚠️ 11 servers have no Prometheus target configured at all. James knows.
> This is on your list to fix in Week 5.

### Ansible

Callum had Ansible installed on his laptop. There are no playbooks in any shared
location. He ran everything ad-hoc and never wrote it down.

The inventory he was using (from memory): HC-DC01, HC-APP01, HC-MON01 plus
the three unidentified servers.

---

## STAGE 4 — MONITORING ← NOT DOCUMENTED

> I don't have enough detail on this to document it properly.
> What I know:
> - Prometheus scrapes node_exporter on the Linux hosts
> - Windows Exporter is installed on HC-DC01 (Callum did this)
> - There is a Grafana dashboard called "Harrington Capital" but I have never
>   seen it fully working — half the panels showed no data last time I looked
> - There are NO alert rules configured in Grafana. Zero. This is why we didn't
>   get alerted about the disk filling up before it hit 97%.

---

## STAGE 5 — INCIDENT MANAGEMENT ← NOT DOCUMENTED

> Callum managed incidents informally — Teams messages and a shared Excel
> spreadsheet on SharePoint that I cannot find. No GLPI. No formal process.
> Marcus Webb has been asking James to fix this for months.
> The P1 incident six weeks ago (HC-APP01 disk full) was never formally closed
> and no RCA was filed. Marcus has flagged this twice.

---

## STAGE 6 — BACKUP AND DR ← NOT DOCUMENTED

> There is a scheduled task on HC-DC01 called `HC-NightlyBackup`.
> I have never looked at what it does or where it writes.
> I believe it backs up something to a local path on HC-DC01 — possibly
> `C:\Backups\` but I am not certain.
> The last time anyone verified a restore was working: unknown. Callum said
> "it's fine" in December. Not good enough for DORA.

---

## STAGE 7 — AUTOMATION ← NOT DOCUMENTED

> Callum had PowerShell scripts on his laptop.
> IT wiped the laptop before anyone could extract them.
> I remember he had something for disk checking and something for user
> provisioning but I never saw the scripts.

---

## STAGE 8 — CHANGE MANAGEMENT ← NOT DOCUMENTED

> Changes go through CAB on Thursdays at 14:00.
> Emergency changes can be applied immediately but must be retrospectively
> submitted to Marcus Webb within 24 hours.
> There is no formal CR template that I am aware of. Callum submitted
> freeform emails. Marcus hated this.

---

## THINGS I KNOW THAT AREN'T WRITTEN DOWN ANYWHERE ELSE

1. The `allow-legacy-api` NSG rule on port 8081 — Callum once mentioned this
   connects to an old pricing feed integration. He said it was "being decommissioned"
   in Q4 2025. It is now Q2 2026. Worth investigating.

2. HC-APP01 disk fills up because Docker is not configured with log rotation.
   Container logs write to `/var/lib/docker/containers/[id]/*.log` with no size limit.
   This is almost certainly what caused both disk incidents. Callum's fix was
   `docker system prune` — treating the symptom not the cause.

3. The three unidentified VMs (10.0.3.41–43) — James thinks these might be from
   a proof-of-concept that Callum ran before Christmas. Nobody decommissioned them.
   They have been running for six months costing money. Worth checking with James.

4. Grafana default admin password has never been changed from `admin/admin`.
   Marcus does not know this yet. Fix it quietly.

5. The `svc_backup` service account password was set to never expire by Callum.
   It is also a Domain Admin. Marcus definitely does not know this.
   Fix: remove Domain Admin, set password expiry, document in GLPI.

---

*These notes are incomplete and may contain errors.*
*Treat everything with a CHECK THIS marker as unverified.*
*Do not make changes based on this document without confirming current state first.*
*— Priya Sharma, 2026-04-14*
