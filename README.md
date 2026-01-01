# Agent Harness (N100 + Coder)

Purpose-built home for the OpticWorks agent harness. This repo consolidates
N100 access, Coder workspace configuration, and the operational workflow for the
`opticworks-dev` template so it can evolve alongside agent features (MCP servers,
skills, and workspace baselines).

## What Lives Here

- `AGENTS.md`: live workspace snapshot for the active Coder node.
- `templates/opticworks-dev/`: Coder workspace template (main.tf, Dockerfile).
- `docs/n100-coder-access.md`: access guide for N100 and Coder.
- `docs/coder-workspace.md`: workspace baseline and how to refresh it.
- `mcp/`: MCP server configs and docs.
- `skills/`: agent skills and references.

## Workspace Bootstrap

New workspaces automatically:
1. Clone this repo to `~/agent-harness`
2. Symlink `AGENTS.md` to home directory for agent discovery
3. Configure SSH access to N100 node
4. Set up GitHub, Claude Code, and Codex authentication (from Infisical)

## Template Updates

The `opticworks-dev` template source is tracked in `templates/opticworks-dev/`.

To deploy changes:

```bash
# From any machine with SSH access to N100
scp templates/opticworks-dev/* n100:/home/claude-temp/coder-templates/opticworks-dev/

ssh n100 "export CODER_URL='https://coder.hardwareos.com' && \
  export CODER_SESSION_TOKEN='\$CODER_ADMIN_TOKEN' && \
  coder templates push opticworks-dev --directory /home/claude-temp/coder-templates/opticworks-dev --yes"
```

After pushing, update `AGENTS.md` and `docs/coder-workspace.md` to reflect any
workspace changes.

## Required Infisical Secrets

| Secret | Purpose |
|--------|---------|
| `GITHUB_TOKEN` | GitHub CLI and git push access |
| `CLAUDE_CREDENTIALS_JSON` | Claude Code authentication |
| `CODEX_AUTH_JSON` | OpenAI Codex authentication |
| `N100_SSH_KEY` | SSH access to N100 node from workspaces |
| `CODER_ADMIN_TOKEN` | Coder API access for template management |

## Contributing

- Keep secrets out of this repo; document them instead.
- Prefer short, purpose-built docs over generic system writeups.
- Update `AGENTS.md` whenever the workspace environment changes.
