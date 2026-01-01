# N100 + Coder Access (Harness)

This document is the harness-focused access guide for the N100 node and its
Coder workspaces. It replaces scattered references across product repos.

## Entry Points

| Resource | URL/Address | Auth |
|----------|-------------|------|
| Coder UI | https://coder.hardwareos.com | Username/password |
| SSH to N100 | ssh.hardwareos.com | SSH key via cloudflared |
| Home Assistant | https://ha.hardwareos.com | HA login |
| N100 LAN IP | 192.168.0.148 | Local network only |

## SSH to N100 (Cloudflared)

Add to `~/.ssh/config`:

```ssh-config
Host n100
  HostName ssh.hardwareos.com
  User claude-temp
  IdentityFile ~/.ssh/your-key
  ProxyCommand cloudflared access ssh --hostname ssh.hardwareos.com
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

Connect:

```bash
ssh n100
```

## Coder CLI Basics

```bash
export CODER_URL="https://coder.hardwareos.com"
export CODER_SESSION_TOKEN="your-token-here"

coder list
coder create my-workspace --template opticworks-dev
coder start my-workspace
coder ssh my-workspace -- ls -la
coder stop my-workspace
```

## Agent Requirements

| Requirement | Where It Lives |
|-------------|----------------|
| Coder API token | Infisical or local env |
| Coder URL | https://coder.hardwareos.com |
| Workspace name | Coder API or pre-provisioned |
| SSH access | `coder ssh <workspace>` |

## Infisical Injection

Workspaces auto-inject secrets at startup. These are written to
`/home/coder/.env.secrets` and sourced by `.bashrc`.

```bash
# Example usage
cat ~/.env.secrets
```

## Template Location (N100)

The `opticworks-dev` template is not stored in this repo.

```bash
ssh n100
cd /home/claude-temp/coder-templates/opticworks-dev/
# Edit main.tf or Dockerfile
coder templates push opticworks-dev --yes
```
