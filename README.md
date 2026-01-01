# Agent Harness (N100 + Coder)

This repo captures the N100 node access/workspace configuration and documents the
Coder template used for OpticWorks development. It is intended to be the single
source of truth for agent harness updates (Coder template, MCP servers, skills,
workspace baselines).

## Contents

- `AGENTS.md`: current Coder workspace snapshot for the N100 node.
- `docs/n100-coder-access.md`: N100 and Coder access guide.
- `docs/coder-workspace.md`: workspace specifics for the RS-1 Coder environment.
- `mcp/`: MCP server configs and docs (placeholders for now).
- `skills/`: agent skills and references (placeholders for now).

## Updating the Coder Template

The `opticworks-dev` template currently lives on the N100 node (not in this repo).
To update it:

```bash
ssh n100
cd /home/claude-temp/coder-templates/opticworks-dev/
# Edit main.tf or Dockerfile
coder templates push opticworks-dev --yes
```

After updating the template, update documentation in this repo to reflect changes.

## Adding MCP Servers or Skills

- Put MCP configs/docs under `mcp/`.
- Put skill docs/assets under `skills/`.
- Keep changes documented in `AGENTS.md` if they affect the workspace footprint.
