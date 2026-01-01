# Agent Harness

A bootstrap environment for AI agents running in Coder workspaces. The harness
provides immediate access to tooling, secrets, repositories, and documented
workflows so agents can be productive from the first prompt.

## Purpose

When a new Coder workspace is created using the `opticworks-dev` template, this
repo is automatically cloned and configured. Agents (Claude, Codex, Gemini, etc.)
can read `~/AGENTS.md` to immediately understand:

- **What tools and CLIs are available** (and how to verify they work)
- **What secrets exist** (API keys, tokens, credentials)
- **What repos exist** and how to access them
- **Common workflows** for development, testing, and deployment
- **How to access hardware** (N100 host, Luckfox, serial devices)

## How It Works

```
┌─────────────────────────────────────────────────────────────────────┐
│  New Coder Workspace Created (opticworks-dev template)              │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Startup Script Runs:                                               │
│  1. Fetch secrets from Infisical → ~/.env.secrets                   │
│  2. Configure GitHub CLI (gh auth)                                  │
│  3. Configure Claude Code (~/.claude/.credentials.json)             │
│  4. Configure Codex (~/.codex/auth.json)                            │
│  5. Configure SSH to N100 (~/.ssh/n100)                             │
│  6. Clone agent-harness → ~/agent-harness                           │
│  7. Symlink ~/AGENTS.md → ~/agent-harness/AGENTS.md                 │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Agent Reads ~/AGENTS.md                                            │
│  → Understands environment, tools, secrets, repos, workflows        │
│  → Starts working immediately                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
agent-harness/
├── AGENTS.md                    # Primary agent orientation (symlinked to ~/)
├── README.md                    # This file (for humans)
├── templates/
│   └── opticworks-dev/          # Coder workspace template
│       ├── main.tf              # Terraform configuration
│       └── Dockerfile           # Workspace image
├── docs/
│   ├── n100-coder-access.md     # N100 and Coder access guide
│   └── coder-workspace.md       # Workspace capabilities reference
├── mcp/                         # MCP server configurations
└── skills/                      # Agent skill definitions
```

## For Agents

**Start here:** Read `~/AGENTS.md` (or `~/agent-harness/AGENTS.md`)

It contains:
- Quick environment verification commands
- Available secrets and how to access them
- Repository list with clone commands
- Common workflows (git, testing, deployment)
- Hardware access instructions
- Troubleshooting guides

## For Humans

### Creating a Workspace

```bash
# Via Coder CLI
coder create my-workspace --template opticworks-dev

# Via Coder UI
# Navigate to https://coder.hardwareos.com → Create Workspace
```

### Updating the Template

The template source lives in `templates/opticworks-dev/`. To deploy changes:

```bash
# Copy template to N100
scp templates/opticworks-dev/* n100:/home/claude-temp/coder-templates/opticworks-dev/

# Push template update
ssh n100 "export CODER_URL='https://coder.hardwareos.com' && \
  export CODER_SESSION_TOKEN='\$CODER_ADMIN_TOKEN' && \
  coder templates push opticworks-dev \
    --directory /home/claude-temp/coder-templates/opticworks-dev --yes"
```

### Required Infisical Secrets

These secrets are injected into every workspace:

| Secret | Purpose | Auto-configured |
|--------|---------|-----------------|
| `GITHUB_TOKEN` | GitHub CLI and git push | Yes (gh auth) |
| `CLAUDE_CREDENTIALS_JSON` | Claude Code authentication | Yes (~/.claude/) |
| `CODEX_AUTH_JSON` | OpenAI Codex authentication | Yes (~/.codex/) |
| `N100_SSH_KEY` | SSH to N100 host | Yes (~/.ssh/n100) |
| `ANTHROPIC_API_KEY` | Anthropic API | No (env var only) |
| `OPENAI_API_KEY` | OpenAI API | No (env var only) |
| `CODER_ADMIN_TOKEN` | Template management | No (env var only) |

## Extending the Harness

### Adding New Secrets

1. Add secret to Infisical (dev environment)
2. Document in `AGENTS.md` under "Available secrets"
3. If auto-configuration needed, update `templates/opticworks-dev/main.tf`

### Adding New Repos

1. Document in `AGENTS.md` under "OpticWorks Repos"
2. Add quick commands if applicable

### Adding MCP Servers

1. Add config to `mcp/`
2. Document in `mcp/README.md`
3. Update `AGENTS.md` if agents should know about it

### Adding Skills

1. Add skill definition to `skills/`
2. Document in `skills/README.md`

## Contributing

- Keep `AGENTS.md` concise and actionable - it's the primary agent interface
- Document secrets by name, never commit actual values
- Test template changes by creating a fresh workspace
- Update docs when workspace capabilities change
