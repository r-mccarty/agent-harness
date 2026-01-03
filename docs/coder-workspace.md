# Workspace Capabilities

Reference for what's available in workspaces created from the `opticworks-dev`
template. For the agent-facing quick reference, see `AGENTS.md`.

## Template: opticworks-dev

| Property | Value |
|----------|-------|
| **Base Image** | Ubuntu 24.04 LTS |
| **Host** | Intel N100 Mini PC (4 cores, 16 GB RAM) |
| **Network** | Host networking (access to 172.32.0.x, 192.168.x.x) |
| **Privileges** | Privileged mode (USB/device passthrough) |

## Installed Software

### Languages & Runtimes

| Tool | Version | Notes |
|------|---------|-------|
| Go | 1.23.4 | `/usr/local/go/bin` |
| Node.js | 22.x LTS | Via nodesource |
| Python | 3.x | System python3 |
| Rust | latest | Via rustup |

### AI CLIs

| Tool | Command | Auth Source |
|------|---------|-------------|
| Claude Code | `claude` | `CLAUDE_CREDENTIALS_JSON` |
| OpenAI Codex | `codex` | `CODEX_AUTH_JSON` |
| Gemini CLI | `gemini` | `GOOGLE_API_KEY` |
| OpenCode | `opencode` | Various |

### Development Tools

| Tool | Purpose |
|------|---------|
| `gh` | GitHub CLI |
| `git` | Version control |
| `jq` | JSON processing |
| `curl`, `wget` | HTTP clients |
| `vim`, `nano` | Editors |
| `tmux`, `screen` | Terminal multiplexers |

### Hardware Tools

| Tool | Purpose |
|------|---------|
| `adb` | Android Debug Bridge (Luckfox) |
| `picocom` | Serial console |
| `minicom` | Serial console (alternative) |
| `lsusb` | USB device listing |

## Auto-Configuration on Startup

The workspace startup script performs these configurations:

### 1. Secrets Injection

```
Infisical (dev/staging/prod) → ~/.env.secrets → sourced in .bashrc
```

### 2. GitHub CLI

```bash
# If GITHUB_TOKEN exists:
gh auth login --with-token
gh auth setup-git
git config --global user.name/email (from GitHub profile)
```

### 3. Claude Code

```bash
# If CLAUDE_CREDENTIALS_JSON exists:
~/.claude/.credentials.json         ← $CLAUDE_CREDENTIALS_JSON
~/.config/claude-code/auth.json     ← $CLAUDE_CREDENTIALS_JSON
```

### 4. Codex

```bash
# If CODEX_AUTH_JSON exists:
~/.codex/auth.json ← $CODEX_AUTH_JSON
```

### 5. N100 SSH Access

```bash
# If N100_SSH_KEY exists:
~/.ssh/n100 ← $N100_SSH_KEY
~/.ssh/config ← Host n100 configuration
```

### 6. Agent Harness

```bash
git clone https://github.com/r-mccarty/agent-harness ~/agent-harness
ln -s ~/agent-harness/AGENTS.md ~/AGENTS.md
```

## Dashboard Indicators

The Coder dashboard shows these status indicators:

| Indicator | What It Means |
|-----------|---------------|
| `Secrets: N loaded` | N secrets in ~/.env.secrets |
| `GitHub: Connected` | gh auth status succeeds |
| `Claude: Authenticated` | ~/.claude/.credentials.json exists |
| `Codex: Authenticated` | ~/.codex/auth.json exists |
| `N100 SSH: Configured` | ~/.ssh/n100 exists |
| `Agent Harness: Ready` | ~/agent-harness directory exists |

## Volume Persistence

| Path | Persisted | Notes |
|------|-----------|-------|
| `/home/coder` | Yes | Docker volume |
| `/dev` | No | Host device passthrough |
| `/tmp` | No | Ephemeral |

Workspace restarts preserve `/home/coder`, including:
- Cloned repos in `~/workspace/`
- Configuration in `~/.config/`, `~/.ssh/`, etc.
- Secrets in `~/.env.secrets`

## Network Access

With host networking, workspaces can reach:

| Target | Address | Purpose |
|--------|---------|---------|
| N100 localhost | 127.0.0.1 | Coder, Docker |
| Luckfox (RNDIS) | 172.32.0.93 | Dev board |
| LAN devices | 192.168.0.x | Local network |
| Internet | via N100 | Outbound access |
