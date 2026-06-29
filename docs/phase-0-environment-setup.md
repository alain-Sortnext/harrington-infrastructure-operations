# Phase 0 — Environment Setup and Validation
# Harrington Capital plc | Infrastructure Engineer Simulation

---

## Overview

Before any technical work begins you must set up and validate your full
working environment. You cannot progress to Phase 1 until every tool
below is installed, configured, and producing verified output.

**BUILD → VERIFY → SUBMIT on every tool.**

---

## Step 1 — GitHub Repository

### Build

1. Create a GitHub account at https://github.com/signup if you do not have one.
2. Fork or clone the simulation repository:
   `https://github.com/alain-Sortnext/harrington-infrastructure-operations`
3. Clone it locally:

```bash
git clone https://github.com/YOUR-USERNAME/harrington-infrastructure-operations.git
cd harrington-infrastructure-operations
```

4. Install GitHub Desktop if you prefer a GUI: https://desktop.github.com

### Verify

```bash
git log --oneline -3
git remote -v
```

### Submit

- Your repository URL: `https://github.com/YOUR-USERNAME/harrington-infrastructure-operations`
- First commit SHA (copy from `git log --oneline -1`)
- Screenshot of the repository folder structure open in VS Code

---

## Step 2 — Microsoft Azure Free Account

### Build

1. Go to https://azure.microsoft.com/en-gb/free/
2. Create a free account (requires credit card for identity — no charge for free tier).
3. Install Azure CLI:
   - Windows: https://aka.ms/installazurecliwindows
   - Linux/Mac: `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
4. Log in:

```bash
az login
```

5. Create a resource group for the project:

```bash
az group create \
  --name rg-harrington-prod \
  --location uksouth \
  --tags Project=harrington-infrastructure-operations Environment=prod ManagedBy=CLI
```

### Verify

```bash
az account show
az group show --name rg-harrington-prod
```

### Submit

- Screenshot of Azure Portal showing `rg-harrington-prod` resource group
- Copy of `az account show` output (shows subscription ID and account name)

---

## Step 3 — AWS Free Tier Account

### Build

1. Go to https://aws.amazon.com/free/
2. Create a free account.
3. Install AWS CLI v2:
   - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
4. Configure credentials:

```bash
aws configure
# AWS Access Key ID: [paste from IAM console]
# AWS Secret Access Key: [paste from IAM console]
# Default region name: eu-west-2
# Default output format: json
```

### Verify

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
    "UserId": "AIDA...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

### Submit

- Full output of `aws sts get-caller-identity` pasted into your submission

---

## Step 4 — Windows Server 2022 in VirtualBox

### Build

1. Download VirtualBox: https://www.virtualbox.org/wiki/Downloads
2. Download Windows Server 2022 Evaluation (180-day free):
   https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022
3. Create a new VM in VirtualBox:
   - Name: `HC-DC01`
   - Type: Microsoft Windows | Version: Windows 2022 (64-bit)
   - RAM: minimum 4096 MB (4 GB)
   - CPU: 2 cores
   - Disk: 60 GB (dynamically allocated)
4. Mount the ISO and install Windows Server 2022 Datacenter (Desktop Experience).
5. After installation, rename the server:

```powershell
Rename-Computer -NewName "HC-DC01" -Restart
```

### Verify

Take a screenshot showing:
- Windows Server 2022 desktop
- Server name `HC-DC01` visible in System Properties or PowerShell:

```powershell
$env:COMPUTERNAME
```

### Submit

- Screenshot of HC-DC01 desktop showing server name

---

## Step 5 — Ubuntu Server 22.04 LTS in VirtualBox

### Build

1. Download Ubuntu Server 22.04 LTS ISO:
   https://ubuntu.com/download/server
2. Create a new VM in VirtualBox:
   - Name: `HC-APP01`
   - Type: Linux | Version: Ubuntu (64-bit)
   - RAM: 2048 MB
   - CPU: 2 cores
   - Disk: 40 GB
3. During installation, enable OpenSSH server when prompted.
4. After installation, set a static IP or note the DHCP address.
5. Test SSH from your host machine:

```bash
ssh hcadmin@<HC-APP01-IP>
```

### Verify

```bash
uname -a
hostname
ip addr show
```

### Submit

- Screenshot of SSH session showing hostname `HC-APP01` and Ubuntu version

---

## Step 6 — Docker Desktop

### Build

1. Download Docker Desktop:
   - Windows/Mac: https://www.docker.com/products/docker-desktop/
   - Linux: https://docs.docker.com/engine/install/ubuntu/
2. Install and start Docker Desktop.
3. Run the verification container:

```bash
docker run hello-world
```

### Verify

The output must contain:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### Submit

- Full output of `docker run hello-world` pasted into submission

---

## Step 7 — Terraform

### Build

1. Install Terraform:
   - Windows (winget): `winget install HashiCorp.Terraform`
   - Linux: https://developer.hashicorp.com/terraform/install
   - Mac (brew): `brew tap hashicorp/tap && brew install hashicorp/tap/terraform`

### Verify

```bash
terraform version
```

Expected: `Terraform v1.6.x` or higher.

### Submit

- Output of `terraform version` pasted into submission

---

## Step 8 — PowerShell 7

### Build

1. Check current version:

```powershell
$PSVersionTable
```

2. If version is below 7.0, install PowerShell 7:
   https://aka.ms/install-powershell

### Verify

```powershell
$PSVersionTable
```

Must show `PSVersion 7.x.x`.

### Submit

- Output of `$PSVersionTable` pasted into submission

---

## Step 9 — Visual Studio Code

### Build

1. Download VS Code: https://code.visualstudio.com/download
2. Install the following extensions (Ctrl+Shift+X):
   - `hashicorp.terraform` (Terraform)
   - `ms-vscode.powershell` (PowerShell)
   - `ms-azuretools.vscode-docker` (Docker)
   - `redhat.vscode-yaml` (YAML)
   - `yzhang.markdown-all-in-one` (Markdown)
3. Open the cloned repository folder in VS Code:
   `File → Open Folder → harrington-infrastructure-operations`

### Verify

Take a screenshot showing VS Code with the repository folder open and at least 3 extensions visible in the Extensions panel.

### Submit

- Screenshot of VS Code with extensions installed and repository open

---

## Step 10 — Prometheus and Grafana

### Build

**On HC-APP01 or HC-MON01 (Ubuntu):**

Install Prometheus:

```bash
sudo apt update
sudo apt install -y prometheus
sudo systemctl enable prometheus
sudo systemctl start prometheus
```

Install Grafana:

```bash
sudo apt install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install -y grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

### Verify

- Prometheus: open `http://<server-ip>:9090` — Status menu should show.
- Grafana: open `http://<server-ip>:3000` — Login page appears (admin / admin).

### Submit

- Screenshot of Prometheus UI at `/targets` page
- Screenshot of Grafana login page

---

## Step 11 — ITSM Tool (GLPI)

### Build

**Option A — GLPI (recommended for realism):**

```bash
# On Ubuntu HC-APP01
sudo apt install -y apache2 php php-mysql php-curl php-gd php-mbstring \
    php-xml php-xmlrpc php-zip mariadb-server

# Download GLPI
wget https://github.com/glpi-project/glpi/releases/download/10.0.14/glpi-10.0.14.tgz
tar -xzf glpi-10.0.14.tgz -C /var/www/html/
sudo chown -R www-data:www-data /var/www/html/glpi
```

Follow the web installer at `http://<server-ip>/glpi`

**Option B — Jira Service Management Free:**

1. Go to https://www.atlassian.com/software/jira/service-management
2. Sign up for the free tier (up to 3 agents).
3. Create a project named: `Harrington Capital IT Support`

### Verify

Create a test incident ticket:
- Title: `TEST-001 — Environment validation ticket`
- Priority: P3
- Category: Infrastructure

Note the ticket number.

### Submit

- Screenshot of the ITSM tool showing the test ticket
- Ticket ID / number (e.g. `INC-20260601-001` or GLPI ticket #1)

---

## Step 12 — Networking Tools

### Build

Install the following:

```bash
# Ubuntu
sudo apt install -y wireshark nmap dnsutils net-tools traceroute

# Windows (winget)
winget install WiresharkFoundation.Wireshark
```

Download Draw.io Desktop: https://app.diagrams.net or https://github.com/jgraph/drawio-desktop/releases

Install Windows Terminal (Windows): https://aka.ms/terminal

### Verify

```bash
# Linux
dig harrington.local @<HC-DC01-IP>
nslookup harrington.local <HC-DC01-IP>
ping -c 4 <HC-APP01-IP>
traceroute <HC-APP01-IP>
```

### Submit

- Output of `dig` or `nslookup` query
- Output of `ping` and `traceroute`

---

## Phase 0 Complete Checklist

Before submitting, confirm every item below:

| # | Item | Evidence Required |
|---|------|-------------------|
| 1 | GitHub repository URL | URL in submission |
| 2 | First commit SHA | 40-character SHA |
| 3 | Azure Resource Group screenshot | Portal screenshot |
| 4 | AWS identity verification | `aws sts get-caller-identity` output |
| 5 | Windows Server HC-DC01 screenshot | Desktop + server name visible |
| 6 | Ubuntu HC-APP01 SSH screenshot | Terminal showing hostname |
| 7 | `docker run hello-world` output | Full console output |
| 8 | `terraform version` output | Console output |
| 9 | `$PSVersionTable` output | Console output |
| 10 | VS Code with extensions screenshot | Extensions panel visible |
| 11 | Prometheus UI screenshot | `/targets` page |
| 12 | Grafana login page screenshot | Login page at port 3000 |
| 13 | ITSM test ticket screenshot | Ticket number visible |

**All 13 items must be submitted to unlock Phase 1.**
