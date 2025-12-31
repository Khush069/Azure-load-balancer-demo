# Azure Load Balancer Demo

This repository demonstrates **traffic distribution testing** on Azure Load Balancer with multiple backend VMs.

## Setup

- Azure Public Load Balancer
- 2 backend Windows VMs (IIS)
- Session persistence: None
- Health probe: HTTP (Port 80)

## Test Script

Run `Test-LB.ps1` from a client machine:

```powershell
for ($i = 1; $i -le 20; $i++) {
    Invoke-WebRequest -Uri "http://<LB-IP>" -DisableKeepAlive -UseBasicParsing |
    Select-Object -ExpandProperty Content
}
