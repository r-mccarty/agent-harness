FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    sudo \
    vim \
    nano \
    htop \
    tmux \
    jq \
    unzip \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    usbutils \
    picocom \
    minicom \
    screen \
    iproute2 \
    iputils-ping \
    net-tools \
    dnsutils \
    iptables \
    android-tools-adb \
    android-tools-fastboot \
    python3 \
    python3-pip \
    python3-venv \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install Infisical CLI
RUN curl -1sLf "https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh" | bash \
    && apt-get update && apt-get install -y infisical \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23
RUN curl -fsSL https://go.dev/dl/go1.23.4.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="$PATH:/usr/local/go/bin"

# Install Rust
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="$PATH:/root/.cargo/bin"

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install AI CLI tools as root (global install)
RUN npm install -g @anthropic-ai/claude-code @google/gemini-cli @openai/codex

# Create non-root user with sudo
ARG USER=coder
RUN useradd -m -s /bin/bash ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER} \
    && usermod -aG dialout ${USER}

# Switch to coder user for remaining setup
USER ${USER}
WORKDIR /home/${USER}

# Set up paths
ENV GOPATH=/home/${USER}/go
ENV PATH="$PATH:/usr/local/go/bin:${GOPATH}/bin:/home/${USER}/.local/bin"

# Install OpenCode for user
RUN curl -fsSL https://opencode.ai/install | bash || true

# Create directories
RUN mkdir -p /home/${USER}/workspace /home/${USER}/.config /home/${USER}/.ssh
RUN chmod 700 /home/${USER}/.ssh

# Default to bash - Coder agent will override this
CMD ["sleep", "infinity"]
