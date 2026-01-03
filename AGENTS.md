# Agent Harness

This repo bootstraps Coder workspaces with the context agents need to be productive
immediately: tooling, secrets, repo access, and common workflows.

**Location in workspace:** `~/agent-harness` (symlinked to `~/AGENTS.md`)

---

## Quick Orientation

### What You Have Access To

| Category | What's Available |
|----------|------------------|
| **AI CLIs** | `claude`, `codex`, `gemini`, `opencode` (pre-authenticated) |
| **Secrets** | `~/.env.secrets` (auto-loaded from Infisical) |
| **GitHub** | `gh` CLI authenticated, git push works |
| **N100 Host** | `ssh n100` (SSH key pre-configured) |
| **Hardware** | USB passthrough, serial ports, Luckfox access |

### Git Identity (OpticWorks)

- Name: r-mccarty
- Email: ry.mccarty13@gmail.com

### Check Your Environment

```bash
# Verify authentication status
gh auth status                    # GitHub
claude --version                  # Claude Code (runs if authenticated)
cat ~/.env.secrets | wc -l        # Count loaded secrets
ssh n100 "hostname"               # Test N100 access
```

---

## Secrets (Infisical)

Secrets are injected at workspace startup from Infisical and written to `~/.env.secrets`.

```bash
# View all secrets
cat ~/.env.secrets

# Secrets are auto-sourced in bash. Access directly:
echo $GITHUB_TOKEN
echo $ANTHROPIC_API_KEY
```

**Available secrets** (varies by Infisical project):

| Secret | Purpose |
|--------|---------|
| `GITHUB_TOKEN` | GitHub API and git push |
| `ANTHROPIC_API_KEY` | Anthropic API access |
| `OPENAI_API_KEY` | OpenAI API access |
| `CLAUDE_CREDENTIALS_JSON` | Claude Code OAuth (auto-configured) |
| `CODEX_AUTH_JSON` | Codex CLI auth (auto-configured) |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API |
| `N100_SSH_KEY` | SSH to N100 (auto-configured) |
| `X_API_KEY` | X (Twitter) API key |
| `X_API_SECRET` | X API secret |
| `X_ACCESS_TOKEN` | X access token |
| `X_ACCESS_SECRET` | X access token secret |

---

## Repositories

Clone repos to `~/workspace/` for organization. GitHub is pre-authenticated.

### OpticWorks Repos

| Repo | Purpose | Clone |
|------|---------|-------|
| **hardwareOS** | Embedded Linux platform (Go + React) | `gh repo clone r-mccarty/hardwareOS` |
| **presence-detection-engine** | ESP32 + LD2410 presence sensor | `gh repo clone r-mccarty/presence-dectection-engine` |
| **opticworks-intranet** | Internal site (Astro) | `gh repo clone r-mccarty/opticworks-intranet` |
| **opticworks-store** | E-commerce (Next.js + Medusa) | `gh repo clone r-mccarty/opticworks-store` |
| **n8n-marketing-automation** | N8N workflows for X/social media | `gh repo clone r-mccarty/n8n-marketing-automation` |
| **agent-harness** | This repo - workspace bootstrap | Already at `~/agent-harness` |

### Repo Quick Commands

```bash
# hardwareOS (Go + React)
cd ~/workspace/hardwareOS
go test ./...
cd ui && npm run dev

# presence-detection-engine (ESPHome + Python)
cd ~/workspace/presence-detection-engine
cd esphome && platformio test -e native
yamllint esphome/ homeassistant/

# opticworks-intranet (Astro)
cd ~/workspace/opticworks-intranet
npm run dev

# opticworks-store (Next.js + Medusa)
cd ~/workspace/opticworks-store
pnpm dev:frontend

# n8n-marketing-automation (Docker + Python)
cd ~/workspace/n8n-marketing-automation
# Deploy to N100: see SETUP.md
ssh n100 "sudo systemctl status tweet-api"  # Check Tweet API
ssh n100 "docker compose -f /opt/n8n/docker-compose.yml logs -f"  # N8N logs
```

---

## N100 Host Access

The N100 is the physical host running Coder. SSH is pre-configured.

```bash
# Connect to N100
ssh n100

# Run command on N100
ssh n100 "docker ps"
ssh n100 "ls /home/claude-temp/coder-templates/"
```

### What's on the N100

| Service | Purpose |
|---------|---------|
| Coder | Workspace orchestration (port 7080) |
| Home Assistant | Smart home automation |
| N8N | Marketing automation (port 5678) - https://n8n.optic.works |
| Tweet API | X OAuth shim for N8N (port 5680, localhost only) |
| Cloudflared | Tunnel to internet |
| Docker | Container runtime |

### Hardware Connected to N100

| Device | Access |
|--------|--------|
| **Luckfox Pico Max** | `ssh root@172.32.0.93` or `adb shell` |
| **USB devices** | `lsusb` (passthrough enabled) |
| **Serial ports** | `picocom -b 115200 /dev/ttyUSB0` |

---

## Common Workflows

### 1. Work on a Repo

```bash
# Clone and enter
gh repo clone r-mccarty/hardwareOS ~/workspace/hardwareOS
cd ~/workspace/hardwareOS

# Create branch
git checkout -b feature/my-feature

# Work, commit, push
git add . && git commit -m "feat: description"
git push -u origin feature/my-feature

# Create PR
gh pr create --fill
```

### 2. Deploy to Luckfox

```bash
# From presence-detection-engine
ssh n100   # Connect to N100 first (has USB access)
adb push build/firmware.bin /tmp/
adb shell "flash_tool /tmp/firmware.bin"
```

### 3. Run Tests Across Repos

```bash
# ESPHome unit tests
cd ~/workspace/presence-detection-engine/esphome
platformio test -e native

# Go tests
cd ~/workspace/hardwareOS
go test ./...

# Frontend tests
cd ~/workspace/opticworks-intranet
npm test
```

### 4. Access Home Assistant

```bash
# HA is on the N100, accessible via tunnel
curl -H "Authorization: Bearer $HA_TOKEN" \
  https://ha.hardwareos.com/api/states
```

### 5. Work with N8N / Tweet API

```bash
# Access N8N dashboard
open https://n8n.optic.works

# Test Tweet API shim (on N100)
ssh n100 'curl -X POST http://127.0.0.1:5680 \
  -H "Content-Type: application/json" \
  -d "{\"text\": \"Test tweet\"}"'

# Check/restart services
ssh n100 "sudo systemctl status tweet-api"
ssh n100 "sudo systemctl restart tweet-api"
ssh n100 "docker compose -f /opt/n8n/docker-compose.yml restart"

# View logs
ssh n100 "sudo journalctl -u tweet-api -f"
```

---

## Installed Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Go | 1.23.4 | Backend development |
| Node.js | 22.x | Frontend/tooling |
| Python | 3.x | Scripts and tools |
| Rust | latest | Systems programming |
| adb | 1.0.41 | Android/Luckfox access |
| picocom | 3.1 | Serial console |
| gh | latest | GitHub CLI |
| jq | latest | JSON processing |

---

## Anti-Patterns

> **Warning**: These patterns can cause hard-to-debug issues. Avoid them.

### Host Networking (`network_mode = "host"`)

**Never use `network_mode = "host"` in Coder workspace templates.**

```hcl
# BAD - causes workspace isolation to break
resource "docker_container" "workspace" {
  network_mode = "host"  # DON'T DO THIS
}
```

**Why it's bad:**

1. **Port conflicts**: All containers share the host network. If workspace-1 binds
   code-server to `:8080`, workspace-2's code-server fails with `EADDRINUSE`.

2. **Broken isolation**: Containers can see each other's network traffic and services.
   Opening a terminal in workspace-2 might actually connect you to workspace-1.

3. **Wrong hostname in prompts**: The shell prompt `coder@dev-workspace-1` might
   appear in workspace-2 because you're accidentally connected to the wrong container.

**Correct approach:**

```hcl
resource "docker_container" "workspace" {
  # Use default bridge networking (no network_mode specified)
  # Each container gets its own network namespace and localhost

  # For hardware access, add host entries instead:
  host {
    host = "luckfox"
    ip   = "172.32.0.93"
  }

  host {
    host = "n100-host"
    ip   = "172.17.0.1"  # Docker default gateway
  }
}
```

**Also bind services to localhost:**

```bash
# BAD - binds to all interfaces, conflicts with other containers on host network
code-server --bind-addr 0.0.0.0:8080

# GOOD - binds to container's localhost, Coder agent proxies it
code-server --bind-addr 127.0.0.1:8080
```

### Hardcoded Ports Without Isolation

If you must use specific ports, ensure network isolation first (see above).
Alternatively, use dynamic port allocation or let Coder proxy through the agent.

---

## Troubleshooting

### Secrets Not Loading

```bash
# Re-source secrets
source ~/.env.secrets

# Check if file exists
cat ~/.env.secrets
```

---

## Intranet Sync

The intranet mirrors this repo's docs. After updating `AGENTS.md` or anything in `docs/`, run the sync script from the intranet repo:

```bash
cd ~/workspace/opticworks-intranet
./scripts/sync-agent-harness.sh
```

See `docs/intranet-sync.md` for details.

### GitHub Push Fails

```bash
# Check auth status
gh auth status

# Re-authenticate if needed
echo $GITHUB_TOKEN | gh auth login --with-token
```

### Can't SSH to N100

```bash
# Check if key exists
ls -la ~/.ssh/n100

# Test connection
ssh -v n100
```

### Claude/Codex Not Authenticated

```bash
# Check credential files
ls -la ~/.claude/.credentials.json
ls -la ~/.codex/auth.json

# Credentials come from Infisical - check secrets
grep -E "CLAUDE|CODEX" ~/.env.secrets
```

---

## Extending the Harness

This repo is the source of truth for workspace configuration.

| Path | Purpose |
|------|---------|
| `templates/opticworks-dev/` | Coder template (Terraform + Dockerfile) |
| `mcp/` | MCP server configurations |
| `skills/` | Agent skill definitions |
| `docs/` | Extended documentation |

To update the workspace template, see `docs/n100-coder-access.md`.
