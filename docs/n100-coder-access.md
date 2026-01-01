# N100 + Coder Access

How to access the N100 host and manage Coder workspaces.

## Quick Reference

| Resource | URL/Address | Auth |
|----------|-------------|------|
| **Coder UI** | https://coder.hardwareos.com | Username/password |
| **SSH to N100** | `ssh n100` | SSH key (auto-configured in workspaces) |
| **Home Assistant** | https://ha.hardwareos.com | HA login |
| **N100 LAN IP** | 192.168.0.148 | Local network only |

## SSH to N100

### From a Coder Workspace (Automatic)

Workspaces have SSH pre-configured via `N100_SSH_KEY` from Infisical:

```bash
ssh n100
```

### From External Machine (Manual Setup)

1. Install cloudflared
2. Add to `~/.ssh/config`:

```ssh-config
Host n100
  HostName ssh.hardwareos.com
  User claude-temp
  IdentityFile ~/.ssh/your-key
  ProxyCommand cloudflared access ssh --hostname ssh.hardwareos.com
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

3. Connect: `ssh n100`

## Coder CLI

### Authentication

```bash
export CODER_URL="https://coder.hardwareos.com"
export CODER_SESSION_TOKEN="your-token"  # From Infisical: CODER_ADMIN_TOKEN
```

### Common Commands

```bash
# List workspaces
coder list

# Create workspace
coder create my-workspace --template opticworks-dev

# Start/stop
coder start my-workspace
coder stop my-workspace

# SSH into workspace
coder ssh my-workspace

# Run command in workspace
coder ssh my-workspace -- ls -la
```

## Template Management

The `opticworks-dev` template source is tracked in this repo at
`templates/opticworks-dev/`.

### Deploying Template Updates

```bash
# 1. Edit template files locally
vim templates/opticworks-dev/main.tf

# 2. Copy to N100
scp templates/opticworks-dev/* n100:/home/claude-temp/coder-templates/opticworks-dev/

# 3. Push template
ssh n100 "export CODER_URL='https://coder.hardwareos.com' && \
  export CODER_SESSION_TOKEN='\$CODER_ADMIN_TOKEN' && \
  coder templates push opticworks-dev \
    --directory /home/claude-temp/coder-templates/opticworks-dev --yes"
```

### Template Location on N100

```
/home/claude-temp/coder-templates/opticworks-dev/
├── main.tf      # Terraform configuration
└── Dockerfile   # Workspace image
```

## Infisical Secrets

Workspaces auto-inject secrets from Infisical on startup.

### How It Works

1. Startup script fetches secrets from dev/staging/prod environments
2. Secrets written to `~/.env.secrets`
3. File sourced in `.bashrc`

### Adding Secrets

1. Log in to https://app.infisical.com
2. Select project → Add secret to `dev` environment
3. New workspaces will receive the secret on next creation/restart

### Machine Identity Token

The template uses a Machine Identity token (baked into main.tf) to fetch secrets.
This token has read access to the Infisical project.

## Services on N100

| Service | Port | Access |
|---------|------|--------|
| Coder | 7080 | https://coder.hardwareos.com |
| Home Assistant | 8123 | https://ha.hardwareos.com |
| Cloudflared | — | Manages tunnels |
| Docker | — | Container runtime |

## Troubleshooting

### Can't SSH to N100

```bash
# From workspace - check key exists
ls -la ~/.ssh/n100

# From external - check cloudflared
cloudflared --version
ssh -v n100
```

### Coder CLI Not Authenticated

```bash
# Check environment
echo $CODER_URL
echo $CODER_SESSION_TOKEN

# Re-authenticate
export CODER_SESSION_TOKEN="$(cat ~/.env.secrets | grep CODER_ADMIN_TOKEN | cut -d= -f2)"
```

### Template Push Fails

```bash
# Check you're authenticated
coder whoami

# Check template directory exists
ssh n100 "ls -la /home/claude-temp/coder-templates/opticworks-dev/"

# Push with verbose output
ssh n100 "cd /home/claude-temp/coder-templates/opticworks-dev && \
  CODER_URL=https://coder.hardwareos.com \
  CODER_SESSION_TOKEN=\$CODER_ADMIN_TOKEN \
  coder templates push opticworks-dev --yes 2>&1"
```
