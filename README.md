# Agent Harness (N100 + Coder)

Purpose-built home for the OpticWorks agent harness. This repo consolidates
N100 access, Coder workspace configuration, and the operational workflow for the
`opticworks-dev` template so it can evolve alongside agent features (MCP servers,
skills, and workspace baselines).

## What Lives Here

- `AGENTS.md`: live workspace snapshot for the active Coder node.
- `docs/n100-coder-access.md`: access guide for N100 and Coder.
- `docs/coder-workspace.md`: workspace baseline and how to refresh it.
- `mcp/`: MCP server configs and docs.
- `skills/`: agent skills and references.

## Template Updates (N100)

The `opticworks-dev` template lives on the N100 node:

```bash
ssh n100
cd /home/claude-temp/coder-templates/opticworks-dev/
# Edit main.tf or Dockerfile
coder templates push opticworks-dev --yes
```

After pushing, update `AGENTS.md` and `docs/coder-workspace.md` to reflect any
workspace changes.

## Contributing

- Keep secrets out of this repo; document them instead.
- Prefer short, purpose-built docs over generic system writeups.
- Update `AGENTS.md` whenever the workspace environment changes.
