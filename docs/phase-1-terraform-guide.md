# Phase 1 — Azure Infrastructure with Terraform
# Harrington Capital plc | Infrastructure Engineer Simulation

---

## Objective

Deploy Harrington Capital's Azure estate using Terraform (IaC).
No manual portal clicks. Everything as code. Everything committed to GitHub.

**By the end of this phase you will have:**
- Two Azure Resource Groups (prod and dev)
- A Virtual Network with three subnets
- Two Network Security Groups with rules
- Three VMs (1 Windows Server 2022, 2 Ubuntu 22.04)
- All resources tagged and committed to `/terraform` in your repo

---

## BUILD

### Step 1 — Authenticate to Azure

```bash
az login
az account show
```

Note your Subscription ID — you will need it.

### Step 2 — Prepare your tfvars

```bash
cd harrington-infrastructure-operations/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set a secure admin password (min 12 chars, upper + lower + number + symbol).

**Never commit terraform.tfvars** — it is in `.gitignore`.

### Step 3 — Generate an SSH key pair (for Linux VMs)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa.pub
```

The public key path `~/.ssh/id_rsa.pub` matches the default in `terraform.tfvars.example`.

### Step 4 — Initialise Terraform

```bash
terraform init
```

Expected output includes:
```
Terraform has been successfully initialized!
```

### Step 5 — Complete the TODO in main.tf

Open `/terraform/main.tf` and find the TODO comment in `azurerm_network_security_group.mgmt`.

Add the missing security rule:
- Name: `allow-rdp-mgmt-inbound`
- Priority: 100
- Direction: Inbound
- Access: Allow
- Protocol: Tcp
- Source port range: `*`
- Destination port range: `3389`
- Source address prefix: `10.0.3.0/24` (management subnet only)
- Destination address prefix: `*`

### Step 6 — Plan

```bash
terraform plan -out=tfplan.bin
```

Review the plan output. You should see **18 resources to add**.

### Step 7 — Apply

```bash
terraform apply tfplan.bin
```

Type `yes` when prompted (if not using the saved plan).

Wait approximately 5–8 minutes for all VMs to provision.

### Step 8 — Commit your completed main.tf

```bash
git add terraform/main.tf
git commit -m "feat(terraform): add RDP NSG rule - Phase 1 complete"
git push origin main
```

---

## VERIFY

Run these checks after apply completes:

```bash
# Confirm all outputs populated
terraform output

# Confirm resource group exists
az group show --name rg-harrington-prod --query "{name:name, location:location, tags:tags}"

# List all resources in the RG
az resource list --resource-group rg-harrington-prod --output table

# Confirm VMs are running
az vm list --resource-group rg-harrington-prod --output table

# Get public IPs
terraform output dc01_public_ip
terraform output app01_public_ip
terraform output mon01_public_ip
```

Update `ansible/inventory.ini` with the public IPs from the outputs.

---

## SUBMIT

Your Phase 1 submission must include:

| # | Evidence | How to get it |
|---|----------|---------------|
| 1 | `terraform plan` output | Copy the summary: `Plan: X to add, 0 to change, 0 to destroy.` |
| 2 | `terraform apply` output | Copy the final `Apply complete! Resources: X added.` line |
| 3 | `terraform output` | Full output showing all IPs and IDs |
| 4 | Azure Portal screenshot | Resource Group `rg-harrington-prod` showing all resources |
| 5 | GitHub commit URL | URL of your commit adding the RDP NSG rule |
| 6 | Architecture diagram | Draw.io network topology (see `/architecture/README.md`) |

**Anti-fake check:** Your submission must include real Azure Resource IDs.
These only exist if `terraform apply` ran successfully.
Format: `/subscriptions/[guid]/resourceGroups/rg-harrington-prod/providers/...`

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Error: A resource with the ID already exists` | Run `terraform import` or destroy and re-apply |
| `Error: Insufficient quota` | Reduce VM sizes to `Standard_B1s` in `terraform.tfvars` |
| `Error: SSH public key not found` | Run `ssh-keygen` first and verify path in tfvars |
| `Error: authentication failed` | Run `az login` again — token may have expired |
| `Error: admin_password does not meet complexity` | Use a password with upper, lower, number, and symbol |

---

## Architecture Diagram Task

Open Draw.io (https://app.diagrams.net).

Build `hc-network-topology.drawio` using the reference in `/architecture/README.md`.

Include:
- Azure VNet boundary box
- Three subnets (app, data, mgmt) with CIDR labels
- Three VMs with private IP labels
- NSG annotations on app and mgmt subnets
- Internet boundary at the top

Export as PNG (File → Export → PNG, 1920x1080).

Commit both files:

```bash
git add architecture/hc-network-topology.drawio architecture/hc-network-topology.png
git commit -m "docs(architecture): network topology diagram - Phase 1"
git push origin main
```
