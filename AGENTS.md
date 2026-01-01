# Coder Workspace: optic-rs1-dev1

Agent configuration and HIL testing environment for RS-1 development.

## Instance Overview

| Property | Value |
|----------|-------|
| **Hostname** | `optic-rs1-dev1` |
| **URL** | `coder.hardwareos.com` |
| **Host** | Intel N100 Mini PC (4 cores, 16GB RAM) |
| **OS** | Ubuntu 24.04.3 LTS (noble) |
| **Kernel** | 6.14.0-35-generic |
| **Purpose** | RS-1 HIL testing with Luckfox Pico Max |

## Pre-configured Access

| Service | Status | Details |
|---------|--------|---------|
| **GitHub CLI** | Authenticated | Account: `r-mccarty` (missing `read:org` scope) |
| **Infisical Secrets** | Pre-loaded | `~/.env.secrets` present at startup |
| **Docker** | Installed | CLI available; daemon not running (`/var/run/docker.sock` missing) |

## Installed Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Go | 1.23.4 | Backend builds |
| Node.js | 22.21.0 | UI builds |
| Playwright | 1.57.0 | E2E testing & visual screenshots |
| adb | 1.0.41 | Luckfox access |
| rkdeveloptool | 1.0.0 | Rockchip flashing |
| picocom | 3.1 | Serial console |

## Repositories

Local clones of OpticWorks repositories are available in this workspace.

| Repo | Path | Branch | Remote |
|------|------|--------|--------|
| hardwareOS | `/home/coder/workspace/hardwareOS` | `dev` | `https://github.com/r-mccarty/hardwareOS.git` |
| presence-detection-engine | `/home/coder/workspace/presence-detection-engine` | `main` | `https://github.com/r-mccarty/presence-dectection-engine.git` |
| opticworks-intranet | `/home/coder/workspace/opticworks-intranet` | `main` | `https://github.com/r-mccarty/opticworks-intranet.git` |
| opticworks-store | `/home/coder/workspace/opticworks-store` | `main` | `https://github.com/r-mccarty/opticworks-store.git` |

---

## Luckfox Pico Max (Dev Board)

The Luckfox Pico Max (RV1106G3) is used for HIL testing.

Current device status:
- No Rockchip device detected on USB (`lsusb` shows no Rockchip IDs).
- No USB RNDIS interface present (no `enx*` interface).

### Network Interfaces

| Interface | Purpose | IP Address |
|-----------|---------|------------|
| `wlo1` | Wi‑Fi | 192.168.0.148/24 |
| `enp1s0` | Ethernet | down |
| `docker0` | Docker bridge | 172.17.0.1/16 |

Expected when Luckfox is connected:
| Interface | Purpose | IP Address |
|-----------|---------|------------|
| `enx5aef472011ac` | USB RNDIS to Luckfox | 172.32.0.1/24 (host) |
| `enp1s0` | Ethernet to Luckfox | 192.168.1.1/24 (host) |

### Access Methods

| Method | Command | When to Use |
|--------|---------|-------------|
| **ADB** | `sudo adb shell` | Default (USB device mode) |
| **SSH RNDIS** | `ssh root@172.32.0.93` | After RNDIS IP setup |
| **SSH Ethernet** | `ssh root@192.168.1.100` | USB host mode |

### Quick Setup

```bash
# 1. Set up ADB
adb kill-server && sudo adb start-server
sudo adb devices

# 2. Set up RNDIS networking
sudo ip addr add 172.32.0.1/24 dev enx5aef472011ac
ping 172.32.0.93

# 3. Access Luckfox
sudo adb shell
# or
ssh root@172.32.0.93  # password: luckfox
```

---

## HIL Testing Setup

### Current Status

```
┌──────────────────┐                    ┌─────────────────────┐
│      N100        │                    │  Luckfox Pico Max   │
│  (this machine)  │    Not detected    │     (RV1106G3)      │
└──────────────────┘                    └─────────────────────┘
```

### For USB Camera Testing

When USB camera arrives, switch Luckfox to USB host mode:

```
┌──────────────┐    Ethernet       ┌─────────────────────────────┐
│    N100      ├───────────────────┤      Luckfox Pico Max       │
│ 192.168.1.1  │                   │      192.168.1.100          │
└──────────────┘                   │                             │
                                   │  USB-C ──► OTG ──► USB Cam  │
┌──────────────┐   Pin 39 + 38     │                             │
│  5V Power    ├───────────────────┤  GPIO Header (Power In)     │
└──────────────┘                   └─────────────────────────────┘
```

**Required parts:**
- USB-C to USB-A OTG adapter
- 5V 2A power supply
- Dupont jumper wires
- Ethernet cable

See `hardwareOS/docs/rs1/CAMERA_HIL_INTEGRATION.md` for full setup.

---

## Common Commands

```bash
# Luckfox access
sudo adb shell
ssh root@172.32.0.93

# Check USB devices
lsusb | grep Rockchip
sudo adb devices

# Serial console (if needed)
picocom -b 115200 /dev/ttyUSB0

# View secrets
cat ~/.env.secrets

# Git operations
gh repo list
gh pr list
```

## Troubleshooting

### ADB Permission Denied
```bash
adb kill-server
sudo adb start-server
```

### RNDIS Interface Missing
```bash
sudo modprobe -r rndis_host && sudo modprobe rndis_host
ip link show | grep enx
```

### Cannot Ping Luckfox
```bash
# Check interface has IP
ip addr show enx5aef472011ac
# Add if missing
sudo ip addr add 172.32.0.1/24 dev enx5aef472011ac
```

---

## Documentation

| Doc | Location |
|-----|----------|
| Coder workspace | `hardwareOS/docs/platform/CODER_WORKSPACE.md` |
| HIL testing | `hardwareOS/docs/rs1/CAMERA_HIL_INTEGRATION.md` |
| Luckfox setup | `presence-detection-engine/docs/luckfox-pico-max-setup.md` |
| Intranet guide | `opticworks-intranet/CLAUDE.md` |

---

## Playwright Visual Testing

Playwright can be used to capture screenshots for design comparison and validation.

### Quick Start
```bash
cd /home/coder/workspace/opticworks-intranet

# Install browser (first time)
npx playwright install chromium

# Capture design reference screenshots
npx playwright test capture-design-reference --project=chromium

# View screenshots
ls screenshots/
```

### Use Cases
- **Design comparison**: Capture optic.works and intranet side-by-side
- **Contrast validation**: Verify text readability in light/dark modes
- **Before/after changes**: Document visual regressions
- **Cross-browser testing**: Compare rendering across browsers

Screenshots are saved to `opticworks-intranet/screenshots/`.

---

## Repo Quick Commands

### hardwareOS (Go + React)
```bash
./dev_deploy.sh -r <DEVICE_IP>
go test ./...
cd ui && npm run dev
```

### presence-detection-engine (ESPHome + Python)
```bash
cd esphome && esphome compile bed-presence-detector.yaml
cd esphome && platformio test -e native
yamllint esphome/ homeassistant/
```

### opticworks-intranet (Astro)
```bash
npm run dev
npm run build
npm run test
```

### opticworks-store (Next.js + Medusa)
```bash
pnpm dev:frontend
pnpm build:frontend
```
