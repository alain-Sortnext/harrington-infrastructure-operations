# Architecture Diagrams
# Harrington Capital plc -- Infrastructure Operations

---

## Diagrams in this folder

| File | Description | Phase | Tool |
|------|-------------|-------|------|
| hc-network-topology.drawio | Full hybrid network topology | Phase 1 | Draw.io |
| hc-network-topology.png | Exported PNG of above | Phase 1 | Draw.io |
| hc-ad-structure.drawio | Active Directory OU structure | Phase 2 | Draw.io |
| hc-ad-structure.png | Exported PNG of above | Phase 2 | Draw.io |
| hc-monitoring-architecture.drawio | Prometheus/Grafana scrape topology | Phase 5 | Draw.io |
| hc-monitoring-architecture.png | Exported PNG of above | Phase 5 | Draw.io |
| hc-dr-topology.drawio | Disaster recovery architecture | Phase 8 | Draw.io |
| hc-dr-topology.png | Exported PNG of above | Phase 8 | Draw.io |

---

## Network Topology -- Reference (for Draw.io)

Use this reference when building hc-network-topology.drawio in Phase 1.

### Azure (UK South)

```
Internet
    |
Azure Firewall / NSG boundary
    |
vnet-harrington-prod (10.0.0.0/16)
    |
    +-- snet-mgmt   (10.0.3.0/24)  [nsg-mgmt: allow RDP/SSH from mgmt only]
    |       |-- vm-harrington-prod-dc01   (10.0.3.10)  Windows Server 2022 DC
    |       |-- vm-harrington-prod-mon01  (10.0.3.20)  Ubuntu 22.04 Monitoring
    |
    +-- snet-app    (10.0.1.0/24)  [nsg-app: deny SSH from internet]
    |       |-- vm-harrington-prod-app01  (10.0.1.10)  Ubuntu 22.04 App
    |
    +-- snet-data   (10.0.2.0/24)  [reserved -- Phase 8]
```

### On-Premises (VirtualBox)

```
Internal Network (192.168.56.0/24)
    |
    +-- HC-DC01   (192.168.56.10)  Windows Server 2022 -- Domain Controller
    +-- HC-APP01  (192.168.56.20)  Ubuntu 22.04 -- Application
    +-- HC-MON01  (192.168.56.30)  Ubuntu 22.04 -- Prometheus + Grafana
```

---

## Diagram standards

- Use Draw.io default theme (light)
- Azure resources: use Azure icon set (built into Draw.io)
- On-premises: use network server shapes
- Colour code: Azure = blue (#0078D4), On-prem = grey (#555555), Security boundary = red dashed
- Export as both .drawio (source) and .png (evidence)
- PNG minimum resolution: 1920 x 1080
