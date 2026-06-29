# Phase 3 — Linux Hardening with Ansible
# Harrington Capital plc | Infrastructure Engineer Simulation

---

## Objective

Harden HC-APP01 and HC-MON01 against the Harrington Capital ISO 27001
security baseline using Ansible. No manual SSH configuration edits.
Everything automated, everything committed.

**By the end of this phase you will have:**
- SSH password authentication disabled on all Linux hosts
- UFW firewall active with correct rules
- fail2ban protecting SSH from brute-force
- NTP synced to UK pool servers
- Automatic security updates configured
- Ansible PLAY RECAP as evidence

---

## Prerequisites

- Ansible installed on your control machine (your laptop or HC-MON01):

```bash
sudo apt install -y ansible
ansible --version
```

- SSH key-based access from your control machine to HC-APP01 and HC-MON01:

```bash
# If not already set up:
ssh-copy-id hcadmin@<HC-APP01-IP>
ssh-copy-id hcadmin@<HC-MON01-IP>
```

- Inventory file updated with correct IPs:
  Edit `/ansible/inventory.ini` — replace placeholder IPs with real ones.

---

## BUILD

### Step 1 — Test connectivity

```bash
cd harrington-infrastructure-operations/ansible
ansible all -i inventory.ini -m ping
```

Expected output for each host:
```
HC-APP01 | SUCCESS => { "ping": "pong" }
HC-MON01 | SUCCESS => { "ping": "pong" }
```

If any host fails, fix SSH connectivity before proceeding.

### Step 2 — Run the hardening playbook

```bash
ansible-playbook -i inventory.ini harden-linux.yml --diff
```

The `--diff` flag shows exactly what changes are being made to each file.

This will take approximately 3–5 minutes per host. Watch for:
- `changed` — task made a change
- `ok` — already in correct state
- `failed` — error (see Troubleshooting)

### Step 3 — Copy the PLAY RECAP

At the end of the playbook run you will see:

```
PLAY RECAP *******************************************************************
HC-APP01 : ok=18  changed=12  unreachable=0  failed=0  skipped=2  ...
HC-MON01 : ok=18  changed=12  unreachable=0  failed=0  skipped=0  ...
```

Copy this entire PLAY RECAP — paste it into your submission.

### Step 4 — Commit the playbook

```bash
git add ansible/
git commit -m "feat(ansible): Linux hardening playbook applied - Phase 3"
git push origin main
```

---

## VERIFY

SSH into HC-APP01 and run each check:

### Check 1 — SSH password auth disabled

```bash
sudo grep "PasswordAuthentication" /etc/ssh/sshd_config
```

Must show: `PasswordAuthentication no`

### Check 2 — UFW active with correct rules

```bash
sudo ufw status verbose
```

Must show:
```
Status: active
To                Action      From
--                ------      ----
22/tcp            ALLOW IN    Anywhere
443/tcp           ALLOW IN    Anywhere
```

Take a screenshot of this output.

### Check 3 — fail2ban running

```bash
sudo systemctl status fail2ban
sudo fail2ban-client status sshd
```

Must show: `Active: active (running)`

Take a screenshot of this output.

### Check 4 — NTP synced

```bash
timedatectl status
ntpq -p
```

Must show: `System clock synchronized: yes`

### Check 5 — Test SSH key auth (from your control machine)

```bash
ssh hcadmin@<HC-APP01-IP>
# Should connect without password prompt

# Attempt password login (should FAIL):
ssh -o PreferredAuthentications=password hcadmin@<HC-APP01-IP>
# Expected: Permission denied (publickey)
```

---

## SUBMIT

Your Phase 3 submission must include:

| # | Evidence | How to get it |
|---|----------|---------------|
| 1 | Ansible PLAY RECAP | Copy from terminal after playbook run |
| 2 | `sudo ufw status verbose` screenshot | SSH into HC-APP01, run command, screenshot |
| 3 | `sudo systemctl status fail2ban` screenshot | SSH into HC-APP01, run command, screenshot |
| 4 | SSH password rejection output | `ssh -o PreferredAuthentications=password` showing `Permission denied` |
| 5 | GitHub commit URL | Commit with playbook run evidence |

**Anti-fake check:** The PLAY RECAP must show `failed=0` for both hosts.
The `changed` count must be greater than 0 (proves the playbook ran, not just reported).

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Permission denied (publickey)` on ansible run | Run `ssh-copy-id hcadmin@<HOST-IP>` first |
| `UNREACHABLE` for a host | Check VM is running: `ping <HOST-IP>` |
| `FAILED: ufw enable` | Run `sudo apt install -y ufw` manually first |
| Locked out of SSH after hardening | Connect via VirtualBox console: `sudo ufw allow ssh` |
| `fail2ban` not starting | Check: `sudo journalctl -u fail2ban -n 20` |
