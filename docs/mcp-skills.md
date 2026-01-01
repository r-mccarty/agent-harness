# MCP + Skills Layout

This repo is the canonical place for agent harness extensions. Keep configs here
and document any workspace impacts in `AGENTS.md`.

## MCP

- Store MCP server configs under `mcp/`.
- Keep one folder per server when possible.
- Include a short `README.md` describing purpose, auth, and how to enable.

Suggested layout:

```
mcp/
  README.md
  <server-name>/
    README.md
    config.json
    docs.md
```

## Skills

- Store skill docs/assets under `skills/`.
- Keep one folder per skill.
- Include `SKILL.md` and any references/assets alongside it.

Suggested layout:

```
skills/
  README.md
  <skill-name>/
    SKILL.md
    references/
    assets/
```

## Updating the Workspace

1. Add or update MCP/skills files in this repo.
2. Update `AGENTS.md` if the workspace footprint changes.
3. If the template needs changes, edit and push from the N100 node:

```bash
ssh n100
cd /home/claude-temp/coder-templates/opticworks-dev/
# Edit main.tf or Dockerfile
coder templates push opticworks-dev --yes
```
