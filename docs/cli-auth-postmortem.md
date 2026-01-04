# CLI Auth: Codex + Claude Code (Approaches, Assumptions, Outcomes)

This doc records the approaches tried to auto-authenticate Codex and Claude Code in fresh Coder
workspaces, along with the assumptions and observed outcomes. It is a factual summary of the
work done, not a prescription for the final fix.

## Goals

- New Coder workspaces auto-authenticate Codex and Claude Code.
- Avoid interactive OAuth/device login flows.
- Use Infisical secrets + template provisioning only.

## Environment Constraints

- Workspaces are created from `templates/opticworks-dev/`.
- Secrets are injected via Infisical and written to `~/.env.secrets`.
- Provisioning happens at workspace startup; changes require template push to Coder.

## Approaches Tried

### A. Codex: Pre-seed auth JSON

**Assumption**
- Codex CLI will accept a pre-seeded auth JSON file identical to a working Codespaces instance.

**Implementation**
- New Infisical secret `CODEX_AUTH_JSON` containing the auth JSON from an authenticated session.
- Template writes it to `~/.codex/auth.json` (created if missing).
- Added jq normalization to ensure `jq -r` can parse a single-line JSON string and preserve types.

**Outcome**
- Initially reported as working; later user report indicates fresh workspaces are not authenticated.
- Current status (per user): Codex no longer auto-auths in new workspaces.

**Evidence collected**
- No persistent local CLI logs available for Codex; outcome based on user report of prompt behavior.

### B. Claude Code: Pre-seed OAuth credentials

**Assumption**
- Claude Code uses `~/.claude/.credentials.json` or `~/.config/claude-code/auth.json` for auth.
- Placing a valid OAuth bundle (access + refresh token) is sufficient to avoid OAuth flow.

**Implementation**
- Infisical `CLAUDE_CREDENTIALS_JSON` secret written to both:
  - `~/.claude/.credentials.json`
  - `~/.config/claude-code/auth.json`
- File permissions set to `0600`.

**Outcome**
- Not sufficient on its own. Fresh workspaces still prompted for OAuth login.
- Confirmed in workspace `agent-harness-test`: OAuth prompt appears immediately after theme select.

**Evidence collected**
- On affected workspace, user ran:
  - `ls -l ~/.claude/.credentials.json ~/.config/claude-code/auth.json`
  - `cat ~/.claude/.credentials.json | jq '.claudeAiOauth.subscriptionType'` -> `"pro"`
- Yet `claude` still prompted for OAuth.

### C. Claude Code: Add missing scope

**Assumption**
- Claude Code requires `org:create_api_key` in the OAuth `scopes` array to skip onboarding/auth.

**Implementation**
- Updated `CLAUDE_CREDENTIALS_JSON` in Infisical to include `org:create_api_key`.

**Outcome**
- Still reported as prompting for OAuth in new workspaces.

### D. Claude Code: Add settings file to skip onboarding flow

**Assumption**
- Claude Code uses `~/.config/claude-code/settings.json` to determine onboarding completion.
- Missing settings file could trigger theme selection + login prompt even with valid tokens.

**Implementation**
- Added new Infisical secret `CLAUDE_SETTINGS_JSON`.
- Template writes it to `~/.config/claude-code/settings.json` with `0600` perms.
- Settings content seeded from a working environment (minimal keys such as `preferredTheme`,
  `onboardingCompleted`).

**Outcome**
- User reports fresh workspaces still prompt for OAuth after theme selection.

### E. Claude Code: Setup-token method (not applied)

**Assumption**
- The `setup-token` flow described in
  https://github.com/anthropics/claude-code/issues/8938 could replace OAuth.

**Implementation**
- Not implemented yet; referenced as a potential next step only.

**Outcome**
- No outcome; approach pending.

## Template + Secret Changes Made

- Template: `templates/opticworks-dev/main.tf`
  - Writes `CODEX_AUTH_JSON` to `~/.codex/auth.json`.
  - Writes `CLAUDE_CREDENTIALS_JSON` to `~/.claude/.credentials.json` and
    `~/.config/claude-code/auth.json`.
  - Writes `CLAUDE_SETTINGS_JSON` to `~/.config/claude-code/settings.json`.

- Infisical secrets added/updated:
  - `CODEX_AUTH_JSON` (new)
  - `CLAUDE_CREDENTIALS_JSON` (updated scopes)
  - `CLAUDE_SETTINGS_JSON` (new)

## Validation Attempts

- Codex:
  - No standardized local validation beyond user report.
- Claude Code:
  - Running `claude` in a fresh workspace still prompts OAuth.
  - Token file existence + subscription type confirmed via `jq`, yet prompt persists.

## Current Status (Per Latest Report)

- Codex: not auto-authenticated in newly provisioned workspaces.
- Claude Code: still prompts OAuth in newly provisioned workspaces, even with settings + tokens.

## Open Questions / Next Steps

- Confirm the exact file locations and formats used by current Codex CLI versions.
- Determine if Claude Code reads `auth.json` or `.credentials.json` only after first-run bootstrap.
- Validate whether `setup-token` (issue #8938) can generate a non-interactive, portable auth.
- Check whether Claude Code requires a machine-specific device ID or state file beyond settings.

> **Warning**: Avoid overwriting tokens or settings from a logged-in workspace without copying
> the full set of related files (any hidden state directories or per-machine IDs).
