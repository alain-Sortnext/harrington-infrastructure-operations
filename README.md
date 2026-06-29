# Harrington Capital plc — Infrastructure Operations

Enterprise infrastructure repository for the Harrington Capital plc Project Lab simulation.

## Repository Structure

| Folder | Contents |
|--------|---------|
| `/terraform` | Azure IaC — resource groups, VNets, NSGs, VMs |
| `/powershell` | Automation scripts — user provisioning, disk checks, log rotation |
| `/ansible` | Playbooks — Linux hardening, patch baseline |
| `/docker` | Docker Compose files and container configs |
| `/monitoring` | Prometheus config, Grafana dashboard JSON |
| `/runbooks` | Operational runbooks (RB-* naming standard) |
| `/incident-reports` | RCA documents (INC-* naming standard) |
| `/architecture` | Draw.io diagrams and exported PNGs |
| `/screenshots` | Phase evidence screenshots |
| `/evidence` | Exported reports, terraform outputs, tool outputs |

## Naming Standards

- Incidents: `INC-YYYYMMDD-NNN`
- Changes: `CHG-YYYYMMDD-NNN`
- Runbooks: `RB-FUNCTION-VERSION`
- Azure VMs: `vm-harrington-[env]-[role]`
- On-prem servers: `HC-[ROLE][NN]`

## Simulation

**Role:** Infrastructure Engineer (Mid-Level)
**Company:** Harrington Capital plc
**Sector:** UK Financial Services / Hybrid Cloud
**Platform:** Project Lab
