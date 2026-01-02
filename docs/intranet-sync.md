# Intranet Sync (agent-harness -> opticworks-intranet)

The OpticWorks intranet mirrors documentation from this repo to keep the internal wiki accurate.

## Source of Truth

- `agent-harness/AGENTS.md`
- `agent-harness/docs/`

## Sync Command

From the `opticworks-intranet` repo:

```bash
./scripts/sync-agent-harness.sh
```

This copies the files above into:

```
opticworks-intranet/src/content/docs/sources/agent-harness/
```

## When to Run

- After updating `AGENTS.md` or anything under `docs/`
- Before publishing changes to the intranet
