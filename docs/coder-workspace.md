# Workspace Baseline (optic-rs1-dev1)

This file captures the baseline for the N100 Coder workspace used by the agent
harness. `AGENTS.md` is the live snapshot; this document summarizes the stable
expectations and how to refresh the snapshot.

## Snapshot Source

- Live snapshot: `AGENTS.md`
- Update the snapshot after template or host changes.

## Instance Baseline

| Property | Value |
|----------|-------|
| Hostname | optic-rs1-dev1 |
| URL | coder.hardwareos.com |
| Template | opticworks-dev |
| Host | Intel N100 (4 cores, 16 GB RAM) |
| OS | Ubuntu 24.04.3 LTS (noble) |
| Kernel | 6.14.0-35-generic |

## Expected Workspace Capabilities

- Go 1.23.4
- Node.js 22.21.0
- Playwright 1.57.0
- adb 1.0.41
- rkdeveloptool 1.0.0
- picocom 3.1
- GitHub CLI authenticated (account: r-mccarty)
- Infisical secrets at `~/.env.secrets`
- Docker CLI installed (daemon may not be running inside the container)

## Hardware Access

The Luckfox Pico Max is used for HIL testing but may be disconnected. When
connected via USB RNDIS, expect an `enx*` interface and access via ADB or SSH.

## Repo Baseline

| Repo | Path |
|------|------|
| hardwareOS | /home/coder/workspace/hardwareOS |
| presence-detection-engine | /home/coder/workspace/presence-detection-engine |
| opticworks-intranet | /home/coder/workspace/opticworks-intranet |
| opticworks-store | /home/coder/workspace/opticworks-store |

## Refresh Checklist

1. Update `AGENTS.md` after template/host changes.
2. Verify tool versions if the template changes.
3. Confirm repo list and remotes in `AGENTS.md`.
