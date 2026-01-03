terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "coder" {}
provider "docker" {}

data "coder_provisioner" "me" {}
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

data "coder_parameter" "workspace_type" {
  name         = "workspace_type"
  display_name = "Workspace Type"
  description  = "Who will use this workspace?"
  default      = "developer"
  mutable      = false

  option {
    name  = "Developer"
    value = "developer"
  }

  option {
    name  = "AI Agent"
    value = "agent"
  }
}

data "coder_parameter" "enable_usb" {
  name         = "enable_usb"
  display_name = "USB/Hardware Access"
  description  = "Enable USB passthrough for Luckfox and other hardware"
  type         = "bool"
  default      = "true"
  mutable      = false
}

resource "coder_agent" "main" {
  arch                   = data.coder_provisioner.me.arch
  os                     = "linux"
  startup_script         = <<-EOT
    #!/bin/bash
    set -e

    # Infisical Machine Identity token and project (baked in for seamless setup)
    INFISICAL_MI_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGl0eUlkIjoiZjMyMDhkZTYtYWUzNC00OTFmLThmM2QtMjlkYTU3MzhiNWYyIiwiaWRlbnRpdHlBY2Nlc3NUb2tlbklkIjoiNDNhNDc4YmYtZDc3OC00ODc4LThkYWYtNzI4YzFjM2JlNzVjIiwiYXV0aFRva2VuVHlwZSI6ImlkZW50aXR5QWNjZXNzVG9rZW4iLCJpYXQiOjE3NjY1NjM5ODYsImV4cCI6MTc2OTE1NTk4Nn0.54e9WtV5WimLdVLTf2W6J2twkqEwh66guDM3Y0xYAE4"
    INFISICAL_PROJECT="42e9e77c-88fa-4cbb-925b-5064c8e3b18c"

    echo "Loading secrets from Infisical (all environments via API)..."

    # Clear/create secrets file
    > ~/.env.secrets

    # Function to fetch secrets from an environment
    fetch_env_secrets() {
      local env="$1"
      echo "  Loading $env environment..."

      response=$(curl -s -H "Authorization: Bearer $INFISICAL_MI_TOKEN" \
        "https://app.infisical.com/api/v3/secrets/raw?workspaceId=$INFISICAL_PROJECT&environment=$env&secretPath=/")

      # Parse JSON and append to secrets file with proper quoting
      if echo "$response" | jq -e '.secrets' > /dev/null 2>&1; then
        # Use jq to properly escape values and wrap in single quotes
        echo "$response" | jq -r '.secrets[] | "\(.secretKey)='"'"'\(.secretValue)'"'"'"' >> ~/.env.secrets
        count=$(echo "$response" | jq '.secrets | length')
        echo "    Loaded $count secrets from $env"
      else
        echo "    Warning: Failed to load $env"
      fi
    }

    # Load from each environment
    for env in dev staging prod; do
      fetch_env_secrets "$env"
    done

    # Remove duplicate keys (keep last occurrence = prod > staging > dev)
    if [ -s ~/.env.secrets ]; then
      tac ~/.env.secrets | awk -F= '!seen[$1]++' | tac > ~/.env.secrets.tmp
      mv ~/.env.secrets.tmp ~/.env.secrets
      chmod 600 ~/.env.secrets
    fi

    # Add to bashrc for future sessions
    grep -q "source ~/.env.secrets" ~/.bashrc 2>/dev/null || \
      echo "set -a; source ~/.env.secrets 2>/dev/null; set +a" >> ~/.bashrc

    # Source for current session
    set -a; source ~/.env.secrets 2>/dev/null || true; set +a

    echo "Secrets loaded from Infisical ($(wc -l < ~/.env.secrets) variables)"

    # Configure GitHub credentials if GITHUB_TOKEN is available
    if [ -n "$GITHUB_TOKEN" ]; then
      echo "Configuring GitHub credentials..."

      # Authenticate gh CLI
      echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null || true

      # Configure git to use gh as credential helper
      gh auth setup-git 2>/dev/null || true

      # Fetch and set git user info from GitHub
      if command -v jq &>/dev/null; then
        gh_user=$(gh api user 2>/dev/null) || true
        if [ -n "$gh_user" ]; then
          name=$(echo "$gh_user" | jq -r '.name // .login')
          email=$(echo "$gh_user" | jq -r '.email // empty')

          [ -n "$name" ] && [ -z "$(git config --global user.name 2>/dev/null)" ] && \
            git config --global user.name "$name"
          [ -n "$email" ] && [ -z "$(git config --global user.email 2>/dev/null)" ] && \
            git config --global user.email "$email"
        fi
      fi

      git config --global init.defaultBranch main 2>/dev/null || true

      echo "GitHub configured: $(gh auth status 2>&1 | grep -o 'Logged in to [^,]*' || echo 'check gh auth status')"
    else
      echo "No GITHUB_TOKEN found, skipping GitHub configuration"
    fi

    # Configure Claude Code credentials if CLAUDE_CREDENTIALS_JSON is available
    if [ -n "$CLAUDE_CREDENTIALS_JSON" ]; then
      echo "Configuring Claude Code credentials..."
      mkdir -p ~/.claude ~/.config/claude-code
      claude_tmp=$(mktemp)
      if command -v jq >/dev/null 2>&1; then
        echo "$CLAUDE_CREDENTIALS_JSON" | jq '.' > "$claude_tmp"
      else
        printf '%s' "$CLAUDE_CREDENTIALS_JSON" > "$claude_tmp"
      fi
      cp "$claude_tmp" ~/.claude/.credentials.json
      cp "$claude_tmp" ~/.config/claude-code/auth.json
      rm -f "$claude_tmp"
      chmod 600 ~/.claude/.credentials.json ~/.config/claude-code/auth.json
      echo "Claude Code credentials configured"
    else
      echo "No CLAUDE_CREDENTIALS_JSON found, skipping Claude Code configuration"
    fi

    # Configure Codex credentials if CODEX_AUTH_JSON is available
    if [ -n "$CODEX_AUTH_JSON" ]; then
      echo "Configuring Codex credentials..."
      mkdir -p ~/.codex
      if command -v jq >/dev/null 2>&1; then
        echo "$CODEX_AUTH_JSON" | jq '.' > ~/.codex/auth.json
      else
        printf '%s' "$CODEX_AUTH_JSON" > ~/.codex/auth.json
      fi
      chmod 600 ~/.codex/auth.json
      echo "Codex credentials configured"
    else
      echo "No CODEX_AUTH_JSON found, skipping Codex configuration"
    fi

    # Configure SSH access to N100 node if N100_SSH_KEY is available
    if [ -n "$N100_SSH_KEY" ]; then
      echo "Configuring SSH access to N100..."
      mkdir -p ~/.ssh
      chmod 700 ~/.ssh
      echo "$N100_SSH_KEY" > ~/.ssh/n100
      chmod 600 ~/.ssh/n100
      cat >> ~/.ssh/config <<'SSHEOF'
Host n100
  HostName 192.168.0.148
  User claude-temp
  IdentityFile ~/.ssh/n100
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host ubuntu-node
  HostName 192.168.0.148
  User claude-temp
  IdentityFile ~/.ssh/n100
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
SSHEOF
      chmod 600 ~/.ssh/config
      echo "N100 SSH access configured"
    else
      echo "No N100_SSH_KEY found, skipping N100 SSH configuration"
    fi

    # Clone agent-harness repo for bootstrap context
    if [ ! -d ~/agent-harness ]; then
      echo "Cloning agent-harness bootstrap repo..."
      git clone https://github.com/r-mccarty/agent-harness.git ~/agent-harness 2>/dev/null || \
        echo "Warning: Failed to clone agent-harness"
    else
      echo "Updating agent-harness..."
      cd ~/agent-harness && git pull --ff-only 2>/dev/null || true
    fi

    # Create symlinks for agent discovery in key locations
    if [ -f ~/agent-harness/AGENTS.md ]; then
      # Symlink to home directory
      ln -sf ~/agent-harness/AGENTS.md ~/AGENTS.md
      ln -sf ~/agent-harness/AGENTS.md ~/CLAUDE.md

      # Symlink to workspace directory (where agents typically start)
      mkdir -p ~/workspace
      ln -sf ~/agent-harness/AGENTS.md ~/workspace/AGENTS.md
      ln -sf ~/agent-harness/AGENTS.md ~/workspace/CLAUDE.md

      echo "Agent harness ready: ~/agent-harness"
      echo "Context files: ~/AGENTS.md, ~/CLAUDE.md, ~/workspace/AGENTS.md, ~/workspace/CLAUDE.md"
    fi

    # Install VS Code extensions
    echo "Installing VS Code extensions..."
    code-server --install-extension Anthropic.claude-code 2>/dev/null || \
      echo "Warning: Claude Code extension installation failed"

    # Start code-server in background (binds to localhost, Coder agent proxies it)
    # IMPORTANT: Binding to 127.0.0.1 ensures each container's code-server is isolated
    code-server --bind-addr 127.0.0.1:8080 --auth none ~/workspace > /tmp/code-server.log 2>&1 &

    echo "Workspace ready!"
    echo "AI CLI tools: claude, gemini, codex, opencode"
    echo "VS Code: Claude Code extension installed"
    echo "Agent context: AGENTS.md and CLAUDE.md in ~ and ~/workspace"
  EOT

  metadata {
    display_name = "CPU Usage"
    key          = "cpu_usage"
    script       = "top -bn1 | grep Cpu | awk \"{print \\$2}\" | cut -d. -f1"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage"
    key          = "mem_usage"
    script       = "free -m | awk \"NR==2{printf \\\"%.0f%%\\\", \\$3*100/\\$2}\""
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "USB Devices"
    key          = "usb_devices"
    script       = "lsusb 2>/dev/null | wc -l || echo 0"
    interval     = 30
    timeout      = 5
  }

  metadata {
    display_name = "Secrets"
    key          = "secrets_status"
    script       = "[ -f ~/.env.secrets ] && echo \"$(wc -l < ~/.env.secrets) loaded\" || echo None"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "GitHub"
    key          = "github_status"
    script       = "gh auth status 2>&1 | grep -q 'Logged in' && echo Connected || echo None"
    interval     = 60
    timeout      = 5
  }

  metadata {
    display_name = "Claude"
    key          = "claude_status"
    script       = "[ -f ~/.claude/.credentials.json ] && echo Authenticated || echo None"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "Codex"
    key          = "codex_status"
    script       = "[ -f ~/.codex/auth.json ] && echo Authenticated || echo None"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "N100 SSH"
    key          = "n100_ssh_status"
    script       = "[ -f ~/.ssh/n100 ] && echo Configured || echo None"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "Agent Harness"
    key          = "harness_status"
    script       = "[ -d ~/agent-harness ] && echo Ready || echo None"
    interval     = 60
    timeout      = 1
  }
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "VS Code"
  url          = "http://localhost:8080/?folder=/home/coder/workspace"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:8080/healthz"
    interval  = 5
    threshold = 6
  }
}

resource "docker_image" "workspace" {
  name = "opticworks-dev-${data.coder_workspace.me.id}"
  build {
    context    = "./"
    dockerfile = "Dockerfile"
  }
  triggers = {
    dockerfile_hash = filemd5("${path.module}/Dockerfile")
  }
}

resource "docker_container" "workspace" {
  count    = data.coder_workspace.me.start_count
  name     = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  image    = docker_image.workspace.image_id
  hostname = data.coder_workspace.me.name

  # Keep privileged for USB/device access
  privileged = true

  # IMPORTANT: Do NOT use network_mode = "host"
  # Host networking causes all containers to share the same network namespace,
  # leading to port conflicts (e.g., code-server on :8080) and broken isolation.
  # Default bridge networking gives each container its own localhost.
  # See: AGENTS.md -> Anti-Patterns -> Host Networking

  # Add routes to reach hardware on the LAN
  host {
    host = "luckfox"
    ip   = "172.32.0.93"
  }

  # N100 host access via Docker's default gateway
  host {
    host = "n100-host"
    ip   = "172.17.0.1"
  }

  user = "coder"

  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
  ]

  volumes {
    volume_name    = "coder-${data.coder_workspace.me.id}-home"
    container_path = "/home/coder"
    read_only      = false
  }

  volumes {
    host_path      = "/dev"
    container_path = "/dev"
    read_only      = false
  }

  entrypoint = ["sh", "-c", coder_agent.main.init_script]
}

resource "docker_volume" "home" {
  name = "coder-${data.coder_workspace.me.id}-home"
  lifecycle {
    ignore_changes = all
  }
}
