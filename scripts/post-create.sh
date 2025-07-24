#!/bin/bash
set -e

echo "Starting post-create setup..."

# Get architecture information
ARCH=$(uname -m)
OS=$(uname -s)

echo "Detected architecture: $ARCH"
echo "Detected OS: $OS"

# Function to clean up any conflicting files from previous installations
cleanup_installation_conflicts() {
    echo "Cleaning up any conflicting installation files..."
    
    # Remove any terraform license files that might conflict
    cd /workspaces/orc.showsite.infra
    rm -f terraform_*.zip LICENSE LICENSE.txt 2>/dev/null || true
    
    # Remove any other temporary installation artifacts
    rm -f kubectl helm flux kubeconform talosctl krew-*.tar.gz *.tar.gz 2>/dev/null || true
    
    echo "✓ Installation conflicts cleaned up"
}

# Function to install essential packages
install_essential_packages() {
    echo "Installing essential packages..."
    
    sudo apt-get update
    sudo apt-get install -y \
        curl \
        wget \
        git \
        unzip \
        jq \
        build-essential \
        fonts-powerline \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
        python3 \
        python3-pip \
        python3-venv \
        zsh \
        bash-completion
    
    echo "✓ Essential packages installed"
}

# Function to install kubectl
install_kubectl() {
    echo "Installing kubectl..."
    
    if ! command -v kubectl &> /dev/null; then
        case "$ARCH" in
            x86_64|amd64)
                KUBECTL_ARCH="amd64"
                ;;
            arm64|aarch64)
                KUBECTL_ARCH="arm64"
                ;;
            *)
                echo "Warning: Unsupported architecture $ARCH for kubectl"
                return 1
                ;;
        esac
        
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${KUBECTL_ARCH}/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        echo "✓ kubectl installed successfully"
    else
        echo "✓ kubectl already installed"
    fi
}

# Function to install helm
install_helm() {
    echo "Installing helm..."
    
    if ! command -v helm &> /dev/null; then
        curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
        sudo apt-get update
        sudo apt-get install -y helm
        echo "✓ helm installed successfully"
    else
        echo "✓ helm already installed"
    fi
}

# Function to install terraform
install_terraform() {
    echo "Installing terraform..."
    
    if ! command -v terraform &> /dev/null; then
        case "$ARCH" in
            x86_64|amd64)
                TERRAFORM_ARCH="amd64"
                ;;
            arm64|aarch64)
                TERRAFORM_ARCH="arm64"
                ;;
            *)
                echo "Warning: Unsupported architecture $ARCH for terraform"
                return 1
                ;;
        esac
        
        TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r '.tag_name' | sed 's/v//')
        if [ -n "$TERRAFORM_VERSION" ] && [ "$TERRAFORM_VERSION" != "null" ]; then
            # Create temporary directory for terraform installation to avoid conflicts
            TEMP_DIR=$(mktemp -d)
            cd "$TEMP_DIR"
            
            echo "Installing terraform version $TERRAFORM_VERSION for $TERRAFORM_ARCH..."
            curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TERRAFORM_ARCH}.zip"
            unzip -q "terraform_${TERRAFORM_VERSION}_linux_${TERRAFORM_ARCH}.zip"
            sudo install -o root -g root -m 0755 terraform /usr/local/bin/terraform
            
            # Clean up temporary directory and ensure we're back in workspace
            cd /workspaces/orc.showsite.infra
            rm -rf "$TEMP_DIR"
            echo "✓ terraform installed successfully"
        else
            echo "Warning: Could not determine terraform version"
            return 1
        fi
    else
        echo "✓ terraform already installed"
    fi
}

# Function to install flux
install_flux() {
    echo "Installing flux..."
    
    if ! command -v flux &> /dev/null; then
        case "$ARCH" in
            x86_64|amd64)
                FLUX_ARCH="amd64"
                ;;
            arm64|aarch64)
                FLUX_ARCH="arm64"
                ;;
            *)
                echo "Warning: Unsupported architecture $ARCH for flux"
                return 1
                ;;
        esac
        
        FLUX_VERSION=$(curl -s https://api.github.com/repos/fluxcd/flux2/releases/latest | jq -r '.tag_name')
        if [ -n "$FLUX_VERSION" ] && [ "$FLUX_VERSION" != "null" ]; then
            curl -LO "https://github.com/fluxcd/flux2/releases/download/${FLUX_VERSION}/flux_${FLUX_VERSION#v}_linux_${FLUX_ARCH}.tar.gz"
            tar -xzf "flux_${FLUX_VERSION#v}_linux_${FLUX_ARCH}.tar.gz"
            sudo install -o root -g root -m 0755 flux /usr/local/bin/flux
            rm flux "flux_${FLUX_VERSION#v}_linux_${FLUX_ARCH}.tar.gz"
            echo "✓ flux installed successfully"
        else
            echo "Warning: Could not determine flux version"
            return 1
        fi
    else
        echo "✓ flux already installed"
    fi
}

# Function to install kubeconform
install_kubeconform() {
    echo "Installing kubeconform..."
    
    if ! command -v kubeconform &> /dev/null; then
        case "$ARCH" in
            x86_64|amd64)
                KUBECONFORM_ARCH="amd64"
                ;;
            arm64|aarch64)
                KUBECONFORM_ARCH="arm64"
                ;;
            *)
                echo "Warning: Unsupported architecture $ARCH for kubeconform"
                return 1
                ;;
        esac
        
        KUBECONFORM_VERSION=$(curl -s https://api.github.com/repos/yannh/kubeconform/releases/latest | jq -r '.tag_name')
        if [ -n "$KUBECONFORM_VERSION" ] && [ "$KUBECONFORM_VERSION" != "null" ]; then
            curl -LO "https://github.com/yannh/kubeconform/releases/download/${KUBECONFORM_VERSION}/kubeconform-linux-${KUBECONFORM_ARCH}.tar.gz"
            tar -xzf "kubeconform-linux-${KUBECONFORM_ARCH}.tar.gz"
            sudo install -o root -g root -m 0755 kubeconform /usr/local/bin/kubeconform
            rm kubeconform "kubeconform-linux-${KUBECONFORM_ARCH}.tar.gz"
            echo "✓ kubeconform installed successfully"
        else
            echo "Warning: Could not determine kubeconform version"
            return 1
        fi
    else
        echo "✓ kubeconform already installed"
    fi
}

# Function to install talosctl
install_talosctl() {
    echo "Installing talosctl..."
    
    if ! command -v talosctl &> /dev/null; then
        case "$ARCH" in
            x86_64|amd64)
                TALOS_ARCH="amd64"
                ;;
            arm64|aarch64)
                TALOS_ARCH="arm64"
                ;;
            *)
                echo "Warning: Unsupported architecture $ARCH for talosctl"
                return 1
                ;;
        esac
        
        TALOS_VERSION=$(curl -s https://api.github.com/repos/siderolabs/talos/releases/latest | jq -r '.tag_name')
        if [ -n "$TALOS_VERSION" ] && [ "$TALOS_VERSION" != "null" ]; then
            echo "Installing talosctl version $TALOS_VERSION for $TALOS_ARCH..."
            curl -Lo /tmp/talosctl "https://github.com/siderolabs/talos/releases/download/${TALOS_VERSION}/talosctl-linux-${TALOS_ARCH}"
            sudo install /tmp/talosctl /usr/local/bin/talosctl
            rm /tmp/talosctl
            echo "✓ talosctl installed successfully"
        else
            echo "Warning: Could not determine latest talosctl version"
            return 1
        fi
    else
        echo "✓ talosctl already installed"
    fi
}

# Function to install starship
install_starship() {
    echo "Installing starship..."
    
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        echo "✓ starship installed successfully"
    else
        echo "✓ starship already installed"
    fi
}

# Function to install krew and kubectl plugins
install_krew_and_plugins() {
    echo "Installing krew and kubectl plugins..."
    
    # Install krew if not present
    if ! kubectl krew version &> /dev/null; then
        echo "Installing krew..."
        
        # Create temporary directory for krew installation
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        case "$ARCH" in
            x86_64|amd64)
                KREW_ARCH="amd64"
                ;;
            arm64|aarch64)
                KREW_ARCH="arm64"
                ;;
            *)
                echo "Warning: Unsupported architecture $ARCH for krew"
                return 1
                ;;
        esac
        
        # Download and install krew
        KREW_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/krew/releases/latest | jq -r '.tag_name')
        if [ -n "$KREW_VERSION" ] && [ "$KREW_VERSION" != "null" ]; then
            curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/krew-linux_${KREW_ARCH}.tar.gz"
            tar zxvf "krew-linux_${KREW_ARCH}.tar.gz"
            ./krew-linux_${KREW_ARCH} install krew
            
            # Add krew to PATH in shell configs
            export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
            
            # Clean up
            cd /workspaces/orc.showsite.infra
            rm -rf "$TEMP_DIR"
            
            echo "✓ krew installed successfully"
        else
            echo "Warning: Could not determine krew version"
            cd /workspaces/orc.showsite.infra
            rm -rf "$TEMP_DIR"
            return 1
        fi
    else
        echo "✓ krew already installed"
    fi
    
    # Ensure krew is in PATH for the current session
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
    
    # Add custom plugin indexes
    echo "Adding custom plugin indexes..."
    
    # Add netshoot plugin index
    if ! kubectl krew index list 2>/dev/null | grep -q "netshoot"; then
        echo "Adding netshoot plugin index..."
        kubectl krew index add netshoot https://github.com/nilic/kubectl-netshoot.git || echo "Warning: Failed to add netshoot index"
        echo "✓ netshoot index added"
    else
        echo "✓ netshoot index already added"
    fi
    
    # Install useful kubectl plugins
    echo "Installing kubectl plugins..."
    
    # Install netshoot plugin for network troubleshooting
    if ! kubectl netshoot --help &> /dev/null; then
        echo "Installing netshoot plugin..."
        kubectl krew install netshoot/netshoot || echo "Warning: Failed to install netshoot plugin"
        echo "✓ netshoot plugin installed"
    else
        echo "✓ netshoot plugin already installed"
    fi
    
    # Install some other useful plugins
    useful_plugins=("ctx" "ns" "tree" "get-all" "datree" "graph" "images" "klock" "kluster-capacity" "kubesec-scan" "pod-logs" "print-env" "rabbitmq" "tail" "view-utilization")
    
    for plugin in "${useful_plugins[@]}"; do
        if ! kubectl "$plugin" --help &> /dev/null 2>&1; then
            echo "Installing $plugin plugin..."
            kubectl krew install "$plugin" 2>/dev/null || echo "Note: $plugin plugin installation skipped (may not be available for arm64/amd64)"
        else
            echo "✓ $plugin plugin already installed"
        fi
    done
    
    echo "✓ Krew and kubectl plugins installation completed"
}

# Function to install additional useful tools
install_additional_tools() {
    echo "Installing additional useful tools..."
    
    # Install some useful CLI tools if not present
    tools_to_install=""
    
    if ! command -v bat &> /dev/null; then
        tools_to_install="$tools_to_install bat"
    fi
    
    if ! command -v fd-find &> /dev/null; then
        tools_to_install="$tools_to_install fd-find"
    fi
    
    if ! command -v ripgrep &> /dev/null; then
        tools_to_install="$tools_to_install ripgrep"
    fi
    
    if ! command -v tree &> /dev/null; then
        tools_to_install="$tools_to_install tree"
    fi
    
    if [ -n "$tools_to_install" ]; then
        echo "Installing: $tools_to_install"
        sudo apt-get update
        sudo apt-get install -y $tools_to_install
    fi
    
    echo "✓ Additional tools installation completed"
}

# Function to setup CLI completions
setup_cli_completions() {
    echo "Setting up CLI completions..."
    
    # Create completion directories for both bash and zsh
    mkdir -p ~/.bash_completion.d
    mkdir -p ~/.zsh_completion.d
    
    # Setup kubectl completions
    if command -v kubectl &> /dev/null; then
        kubectl completion bash > ~/.bash_completion.d/kubectl
        kubectl completion zsh > ~/.zsh_completion.d/_kubectl
        echo "✓ kubectl completions configured"
    fi
    
    # Setup helm completions
    if command -v helm &> /dev/null; then
        helm completion bash > ~/.bash_completion.d/helm
        helm completion zsh > ~/.zsh_completion.d/_helm
        echo "✓ helm completions configured"
    fi
    
    # Setup flux completions
    if command -v flux &> /dev/null; then
        flux completion bash > ~/.bash_completion.d/flux
        flux completion zsh > ~/.zsh_completion.d/_flux
        echo "✓ flux completions configured"
    fi
    
    # Setup terraform completions
    if command -v terraform &> /dev/null; then
        terraform -install-autocomplete 2>/dev/null || true
        echo "✓ terraform completions configured"
    fi
    
    # Setup talosctl completions
    if command -v talosctl &> /dev/null; then
        talosctl completion bash > ~/.bash_completion.d/talosctl
        talosctl completion zsh > ~/.zsh_completion.d/_talosctl
        echo "✓ talosctl completions configured"
    fi
    
    # Setup git completions (usually comes with git but let's ensure it's loaded)
    if [ -f /usr/share/bash-completion/completions/git ]; then
        echo "✓ git completions already available"
    fi
    
    # Add completion loading to zshrc (do this first since zsh is now default)
    if command -v zsh &> /dev/null; then
        if [ ! -f ~/.zshrc ]; then
            touch ~/.zshrc
        fi
        if ! grep -q "zsh_completion.d" ~/.zshrc; then
            cat >> ~/.zshrc << 'EOF'

# Load custom zsh completions
if [ -d ~/.zsh_completion.d ]; then
    fpath=(~/.zsh_completion.d $fpath)
    autoload -U compinit
    compinit
fi

EOF
        fi
    fi
    
    # Add completion loading to bashrc
    if ! grep -q "bash_completion.d" ~/.bashrc; then
        cat >> ~/.bashrc << 'EOF'

# Load custom completions
if [ -d ~/.bash_completion.d ]; then
    for completion in ~/.bash_completion.d/*; do
        [ -r "$completion" ] && source "$completion"
    done
fi

# Enable bash completion if available
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

EOF
    fi
    
    echo "✓ CLI completions setup completed"
}

# Function to setup starship configuration
setup_starship_config() {
    echo "Setting up starship configuration..."
    
    # Create starship config directory
    mkdir -p ~/.config
    
    # Create a custom starship config optimized for Kubernetes development
    cat > ~/.config/starship.toml << 'EOF'
# Starship configuration for Kubernetes development

# Get editor completions based on the config schema
"$schema" = 'https://starship.rs/config-schema.json'

# Inserts a blank line between shell prompts
add_newline = true

# Replace the '❯' symbol in the prompt with '➜'
[character]
success_symbol = '[➜](bold green)'
error_symbol = '[➜](bold red)'

# Show kubernetes context and namespace
[kubernetes]
format = 'on [⛵ ($user on )($cluster in )$context \($namespace\)](dimmed green) '
disabled = false
detect_extensions = ['yml', 'yaml']
detect_files = ['k8s', 'Dockerfile', 'skaffold.yaml', 'helm']
detect_folders = ['k8s', 'helm', 'charts']

[kubernetes.context_aliases]
'dev' = 'development'
'prod' = 'production'
'stage' = 'staging'

# Show git information
[git_branch]
symbol = '🌱 '
truncation_length = 20
truncation_symbol = '…'

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'

# Show terraform workspace
[terraform]
format = 'via [💠 $workspace]($style) '

# Show docker context
[docker_context]
format = 'via [🐳 $context](blue bold)'

# Show directory with limited depth
[directory]
truncation_length = 3
truncation_symbol = '…/'
home_symbol = '~'

# Show command duration for long-running commands
[cmd_duration]
min_time = 2_000
format = 'took [$duration](bold yellow)'

# Show memory usage
[memory_usage]
disabled = false
threshold = 70
symbol = '🐏 '

# Show hostname when in remote session
[hostname]
ssh_only = true
format = 'on [$hostname](bold red) '

# Package managers
[package]
symbol = '📦 '

[nodejs]
symbol = '⬢ '

[python]
symbol = '🐍 '
pyenv_version_name = true

# Cloud providers
[aws]
symbol = '☁️  '

[gcloud]
symbol = '☁️  '

EOF

    echo "✓ Starship configuration created"
}

# Function to setup shell enhancements
setup_shell_enhancements() {
    echo "Setting up shell enhancements..."
    
    # Set zsh as default shell if not already set
    if command -v zsh &> /dev/null && [ "$SHELL" != "/bin/zsh" ]; then
        echo "Setting zsh as default shell..."
        sudo chsh -s /bin/zsh $(whoami) 2>/dev/null || echo "Note: Shell change will take effect on next login"
        echo "✓ zsh set as default shell"
    fi
    
    # Ensure starship is configured
    if command -v starship &> /dev/null; then
        # Add starship to bashrc if not already there
        if ! grep -q "starship init bash" ~/.bashrc; then
            echo 'eval "$(starship init bash)"' >> ~/.bashrc
        fi
        
        # Add starship to zshrc if not already there and zsh is available
        if command -v zsh &> /dev/null; then
            if [ ! -f ~/.zshrc ]; then
                touch ~/.zshrc
            fi
            if ! grep -q "starship init zsh" ~/.zshrc; then
                echo 'eval "$(starship init zsh)"' >> ~/.zshrc
            fi
        fi
        
        echo "✓ Starship prompt configured"
    fi
    
    # Add useful aliases to zshrc first (since it's now the default shell)
    if command -v zsh &> /dev/null; then
        if [ ! -f ~/.zshrc ]; then
            touch ~/.zshrc
        fi
        
        # Add krew to PATH in zshrc
        if ! grep -q "KREW_ROOT" ~/.zshrc; then
            cat >> ~/.zshrc << 'EOF'

# Add krew to PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

EOF
        fi
        
        if ! grep -q "# Useful aliases for development" ~/.zshrc; then
            cat >> ~/.zshrc << 'EOF'

# Useful aliases for development
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias k='kubectl'
alias tf='terraform'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Kubernetes aliases
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'

# Flux aliases
alias fget='flux get'
alias flog='flux logs'
alias freconcile='flux reconcile'

# Krew/kubectl plugin aliases (only if plugins are available)
if command -v kubectl &> /dev/null && kubectl krew version &> /dev/null; then
    alias kctx='kubectl ctx'
    alias kns='kubectl ns'
    alias ktree='kubectl tree'
    alias knetshoot='kubectl netshoot'
    
    # Netshoot convenience aliases for common network troubleshooting
    # Interactive shells
    alias netshell='kubectl netshoot run tmp-shell'
    alias nethostshell='kubectl netshoot run tmp-shell --host-network'
    alias netdebug='kubectl netshoot debug'
    
    # One-time network tests (using tmp-shell with -- command)
    alias netping='kubectl netshoot run tmp-shell -- ping'
    alias netcurl='kubectl netshoot run tmp-shell -- curl'
    alias netnslookup='kubectl netshoot run tmp-shell -- nslookup'
    alias netdig='kubectl netshoot run tmp-shell -- dig'
    alias nettelnet='kubectl netshoot run tmp-shell -- telnet'
    alias netnmap='kubectl netshoot run tmp-shell -- nmap'
    alias nethttp='kubectl netshoot run tmp-shell -- http'
    alias nettrace='kubectl netshoot run tmp-shell -- traceroute'
    alias netmtr='kubectl netshoot run tmp-shell -- mtr'
    alias netiperf='kubectl netshoot run tmp-shell -- iperf3'
    alias netiperf_server='kubectl netshoot run tmp-shell -- iperf3 -s'
    alias nettcpdump='kubectl netshoot run tmp-shell -- tcpdump'
    alias netss='kubectl netshoot run tmp-shell -- ss'
    alias netnetstat='kubectl netshoot run tmp-shell -- netstat'
    alias netwget='kubectl netshoot run tmp-shell -- wget'
    alias netgrpcurl='kubectl netshoot run tmp-shell -- grpcurl'
    alias netfortio='kubectl netshoot run tmp-shell -- fortio'
    alias netspeedtest='kubectl netshoot run tmp-shell -- speedtest-cli'
    alias netdrill='kubectl netshoot run tmp-shell -- drill'
    alias nethost='kubectl netshoot run tmp-shell -- host'
    alias netwhois='kubectl netshoot run tmp-shell -- whois'
    
    # Debug specific pods/nodes (requires target as argument, command after --)
    alias netdebug_pod='kubectl netshoot debug'
    alias netdebug_node='kubectl netshoot debug node/'
else
    # Fallback to native kubectl commands
    alias kns='kubectl config set-context --current --namespace'
    alias kctx='kubectl config use-context'
fi

EOF
        fi
    fi
    
    # Add useful aliases to bashrc
    if ! grep -q "# Useful aliases for development" ~/.bashrc; then
        # Add krew to PATH in bashrc
        if ! grep -q "KREW_ROOT" ~/.bashrc; then
            cat >> ~/.bashrc << 'EOF'

# Add krew to PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

EOF
        fi
        
        cat >> ~/.bashrc << 'EOF'

# Useful aliases for development
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias k='kubectl'
alias tf='terraform'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Kubernetes aliases
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'

# Flux aliases
alias fget='flux get'
alias flog='flux logs'
alias freconcile='flux reconcile'

# Krew/kubectl plugin aliases (only if plugins are available)
if command -v kubectl &> /dev/null && kubectl krew version &> /dev/null; then
    alias kctx='kubectl ctx'
    alias kns='kubectl ns'
    alias ktree='kubectl tree'
    alias knetshoot='kubectl netshoot'
    
    # Netshoot convenience aliases for common network troubleshooting
    # Interactive shells
    alias netshell='kubectl netshoot run tmp-shell'
    alias nethostshell='kubectl netshoot run tmp-shell --host-network'
    alias netdebug='kubectl netshoot debug'
    
    # One-time network tests (using tmp-shell with -- command)
    alias netping='kubectl netshoot run tmp-shell -- ping'
    alias netcurl='kubectl netshoot run tmp-shell -- curl'
    alias netnslookup='kubectl netshoot run tmp-shell -- nslookup'
    alias netdig='kubectl netshoot run tmp-shell -- dig'
    alias nettelnet='kubectl netshoot run tmp-shell -- telnet'
    alias netnmap='kubectl netshoot run tmp-shell -- nmap'
    alias nethttp='kubectl netshoot run tmp-shell -- http'
    alias nettrace='kubectl netshoot run tmp-shell -- traceroute'
    alias netmtr='kubectl netshoot run tmp-shell -- mtr'
    alias netiperf='kubectl netshoot run tmp-shell -- iperf3'
    alias netiperf_server='kubectl netshoot run tmp-shell -- iperf3 -s'
    alias nettcpdump='kubectl netshoot run tmp-shell -- tcpdump'
    alias netss='kubectl netshoot run tmp-shell -- ss'
    alias netnetstat='kubectl netshoot run tmp-shell -- netstat'
    alias netwget='kubectl netshoot run tmp-shell -- wget'
    alias netgrpcurl='kubectl netshoot run tmp-shell -- grpcurl'
    alias netfortio='kubectl netshoot run tmp-shell -- fortio'
    alias netspeedtest='kubectl netshoot run tmp-shell -- speedtest-cli'
    alias netdrill='kubectl netshoot run tmp-shell -- drill'
    alias nethost='kubectl netshoot run tmp-shell -- host'
    alias netwhois='kubectl netshoot run tmp-shell -- whois'
    
    # Debug specific pods/nodes (requires target as argument, command after --)
    alias netdebug_pod='kubectl netshoot debug'
    alias netdebug_node='kubectl netshoot debug node/'
else
    # Fallback to native kubectl commands
    alias kns='kubectl config set-context --current --namespace'
    alias kctx='kubectl config use-context'
fi

EOF
    fi

    echo "✓ Shell enhancements configured"
}

# Main installation sequence
echo "Starting comprehensive tool installation..."

# Clean up any conflicts from previous installations first
cleanup_installation_conflicts || echo "Warning: Cleanup had issues"

# Install everything step by step with error handling
install_essential_packages || echo "Warning: Essential packages installation had issues"
install_kubectl || echo "Warning: kubectl installation failed"
install_helm || echo "Warning: helm installation failed" 
install_terraform || echo "Warning: terraform installation failed"
install_flux || echo "Warning: flux installation failed"
install_kubeconform || echo "Warning: kubeconform installation failed"
install_talosctl || echo "Warning: talosctl installation failed"
install_starship || echo "Warning: starship installation failed"
install_krew_and_plugins || echo "Warning: krew and plugins installation had issues"
install_additional_tools || echo "Warning: additional tools installation had issues"
setup_starship_config || echo "Warning: starship configuration setup had issues"
setup_cli_completions || echo "Warning: CLI completions setup had issues"
setup_shell_enhancements || echo "Warning: shell enhancements setup had issues"
cleanup_installation_conflicts || echo "Warning: Cleanup had issues"
# Verification
echo ""
echo "Verifying installations..."

# Check essential tools
tools=(
    "kubectl"
    "helm"
    "terraform"
    "python3"
    "flux"
    "kubeconform"
    "talosctl"
    "starship"
    "curl"
    "jq"
)

all_good=true
for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        version_info=""
        case "$tool" in
            "kubectl")
                version_info=$(kubectl version --client --short 2>/dev/null | head -1 || echo "available")
                ;;
            "helm")
                version_info=$(helm version --short 2>/dev/null || echo "available")
                ;;
            "terraform")
                version_info=$(terraform version 2>/dev/null | head -1 || echo "available")
                ;;
            "python3")
                version_info=$(python3 --version 2>/dev/null || echo "available")
                ;;
            "flux")
                version_info=$(flux version --client 2>/dev/null | head -1 || echo "available")
                ;;
            "kubeconform")
                version_info=$(kubeconform -v 2>/dev/null || echo "available")
                ;;
            "talosctl")
                version_info=$(talosctl version --short 2>/dev/null || echo "available")
                ;;
            "starship")
                version_info=$(starship --version 2>/dev/null || echo "available")
                ;;
            *)
                version_info="available"
                ;;
        esac
        echo "  ✓ $tool: $version_info"
    else
        echo "  ✗ $tool: not found"
        all_good=false
    fi
done

echo ""

# Check krew and plugins
echo "Checking krew and kubectl plugins..."
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if kubectl krew version &> /dev/null; then
    # Get clean krew version
    krew_version=$(kubectl krew version 2>/dev/null | grep "GitTag" | awk '{print $2}' 2>/dev/null || echo "installed")
    echo "  ✓ krew: $krew_version"
    
    # List all installed plugins with versions
    echo "  ✓ kubectl plugins:"
    # Use script command to force TTY mode and get the full table output
    if command -v script &> /dev/null; then
        script -qec "kubectl krew list" /dev/null 2>/dev/null | tail -n +2 | while read -r plugin version rest; do
            if [ -n "$plugin" ] && [ -n "$version" ]; then
                echo "    - $plugin: $version"
            fi
        done
    else
        # Fallback: just list plugin names
        kubectl krew list 2>/dev/null | while read -r plugin; do
            if [ -n "$plugin" ]; then
                echo "    - $plugin"
            fi
        done
    fi
    
    # Check specific plugins
    if kubectl netshoot --help &> /dev/null 2>&1; then
        echo "  ✓ netshoot plugin: available for network troubleshooting"
    else
        echo "  ℹ netshoot plugin: not installed"
    fi
else
    echo "  ✗ krew: not found"
    all_good=false
fi

echo ""
if [ "$all_good" = true ]; then
    echo "🎉 Post-create setup completed successfully!"
else
    echo "⚠️ Post-create setup completed with some missing tools"
fi

echo ""
echo "Notes:"
echo "  - All tools installed via direct downloads with architecture detection"
echo "  - Installation uses temporary directories to avoid workspace file conflicts"
echo "  - CLI completions configured for kubectl, helm, flux, terraform, and talosctl"
echo "  - Starship prompt configured with Kubernetes and development optimizations"
echo "  - ZSH set as default shell with full completion and alias support"
echo "  - Krew installed with useful kubectl plugins (netshoot/netshoot, ctx, ns, tree, get-all)"
echo "  - Netshoot plugin for network troubleshooting with convenient aliases (netping, netcurl, etc.)"
echo "  - Additional aliases for common kubectl, flux, and git operations"
echo "  - No homebrew dependencies for core functionality"
echo "  - Run '.devcontainer/scripts/validate-setup.sh' for detailed validation"
echo "  - Restart your terminal or run 'source ~/.zshrc' to enable all enhancements"
