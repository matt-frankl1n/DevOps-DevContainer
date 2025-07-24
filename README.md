# Development Container Configuration

This directory contains the development container configuration for the Kubernetes infrastructure project. The dev container provides a fully configured, reproducible development environment with all necessary tools pre-installed.

## 🚀 Quick Start

1. **Prerequisites**: Ensure you have VS Code with the Dev Containers extension installed
2. Add repo files to .devcontainer directory in your repository
3. **Open in Container**: VS Code will automatically prompt to reopen in container when you open this repository
4. **Automatic Setup**: All tools and configurations are installed automatically via the post-create script


## 📋 What's Included

### Core Tools

| Tool            | Version | Purpose                        |
| --------------- | ------- | ------------------------------ |
| **kubectl**     | Latest  | Kubernetes command-line tool   |
| **helm**        | Latest  | Package manager for Kubernetes |
| **flux**        | Latest  | GitOps toolkit for Kubernetes  |
| **terraform**   | Latest  | Infrastructure as code tool    |
| **talosctl**    | Latest  | Talos Linux configuration tool |
| **kubeconform** | Latest  | Kubernetes manifest validation |
| **krew**        | Latest  | kubectl plugin manager         |
| **starship**    | Latest  | Modern shell prompt            |

### Kubectl Plugins (via Krew)

- **netshoot** - Network troubleshooting toolkit with 100+ network tools
- **ctx** - Fast Kubernetes context switching
- **ns** - Fast namespace switching
- **tree** - Resource hierarchy visualization
- **get-all** - Get all resources in a namespace

### Development Tools

- **Docker CLI** - Container management
- **Git** - Version control
- **Python 3** - Scripting and automation
- **jq** - JSON processing
- **bat** - Enhanced cat with syntax highlighting
- **fd-find** - Enhanced find command
- **ripgrep** - Fast text search
- **tree** - Directory structure visualization

### Shell Environment

- **ZSH** - Default shell with enhanced features
- **Bash** - Alternative shell with full support
- **Starship** - Modern, fast prompt with Kubernetes context display
- **CLI Completions** - Tab completion for all major tools
- **Custom Aliases** - Shortcuts for common operations

## 🛠 Configuration Files

### Core Configuration

```
.devcontainer/
├── devcontainer.json          # Main dev container configuration
├── README.md                  # This file
├── scripts/
│   ├── post-create.sh         # Main setup script
│   └── setup-zsh.sh          # ZSH configuration helper
└── local-features/
    └── copy-kube-config/      # Kubernetes config mounting
```

### Key Features in devcontainer.json

- **Base Image**: `mcr.microsoft.com/devcontainers/base:ubuntu-22.04`
- **Docker-outside-of-Docker**: Access to host Docker daemon
- **Kubernetes Config Mounting**: Automatic mounting of `~/.kube` and `~/.minikube`
- **VS Code Extensions**: Pre-installed extensions for Kubernetes, YAML, Terraform, etc.
- **ZSH as Default**: Enhanced shell experience

## 🎯 Shell Enhancements

### Starship Prompt Features

The Starship prompt shows:
- **Kubernetes context and namespace** (⛵ context(namespace))
- **Git branch and status** (🌱 branch)
- **Terraform workspace** (💠 workspace)
- **Docker context** (🐳 context)
- **Command execution time** (for commands > 2s)
- **Current directory** with smart truncation

### Pre-configured Aliases

#### Basic Shortcuts
```bash
alias k='kubectl'              # Quick kubectl access
alias tf='terraform'           # Quick terraform access
alias ll='ls -alF'            # Detailed file listing
alias la='ls -A'              # Show hidden files
alias ..='cd ..'              # Go up one directory
alias ...='cd ../..'          # Go up two directories
```

#### Kubernetes Operations
```bash
alias kgp='kubectl get pods'                    # Get pods
alias kgs='kubectl get services'                # Get services
alias kgd='kubectl get deployments'             # Get deployments
alias kctx='kubectl ctx'                        # Switch contexts (plugin)
alias kns='kubectl ns'                          # Switch namespaces (plugin)
alias ktree='kubectl tree'                      # Show resource hierarchy
```

#### Network Troubleshooting (Netshoot)
```bash
# Interactive shells
alias netshell='kubectl netshoot run tmp-shell'    # Interactive netshoot shell
alias nethostshell='kubectl netshoot run tmp-shell --host-network' # Host network shell
alias netdebug='kubectl netshoot debug'            # Debug existing pods/nodes

# One-time network tests
alias netping='kubectl netshoot run tmp-shell -- ping'        # Quick ping test
alias netcurl='kubectl netshoot run tmp-shell -- curl'        # HTTP requests
alias netnslookup='kubectl netshoot run tmp-shell -- nslookup' # DNS lookup
alias netdig='kubectl netshoot run tmp-shell -- dig'          # Advanced DNS
alias netnmap='kubectl netshoot run tmp-shell -- nmap'        # Port scanning
alias nettcpdump='kubectl netshoot run tmp-shell -- tcpdump'  # Packet capture
alias nethttp='kubectl netshoot run tmp-shell -- http'        # HTTPie requests
alias netiperf='kubectl netshoot run tmp-shell -- iperf3'     # Performance testing
alias netwget='kubectl netshoot run tmp-shell -- wget'        # Download files
alias netgrpcurl='kubectl netshoot run tmp-shell -- grpcurl'  # gRPC testing
alias netfortio='kubectl netshoot run tmp-shell -- fortio'    # Load testing
```

#### Flux Operations
```bash
alias fget='flux get'                           # Get flux resources
alias flog='flux logs'                          # View flux logs
alias freconcile='flux reconcile'               # Force reconciliation
```

#### Git Operations
```bash
alias gs='git status'                           # Git status
alias ga='git add'                              # Git add
alias gc='git commit'                           # Git commit
alias gp='git push'                             # Git push
alias gl='git log --oneline'                   # Compact git log
```

## 🔧 Scripts Reference

### Main Setup Script
**File**: `scripts/post-create.sh`

Automatically runs when the container is created. Performs:
- Architecture detection (amd64/arm64)
- Tool installation with version checking
- Shell configuration (ZSH/Bash)
- CLI completions setup
- Starship configuration
- Alias configuration

### Validation Script
**File**: `scripts/validate-setup.sh`

```bash
.devcontainer/scripts/validate-setup.sh
```

Comprehensive validation including:
- Tool availability and versions
- Krew and plugin status
- Shell configuration verification
- Completion setup validation
- Alias functionality check

### Completion Testing
**File**: `scripts/test-completions.sh`

```bash
.devcontainer/scripts/test-completions.sh
```

Tests CLI completions for:
- kubectl commands and resources
- helm charts and releases
- flux resources and commands
- terraform files and workspaces

### Krew Plugin Testing
**File**: `scripts/test-krew.sh`

```bash
.devcontainer/scripts/test-krew.sh
```

Tests kubectl plugins:
- Lists installed plugins
- Validates plugin functionality
- Shows usage examples
- Demonstrates netshoot capabilities

## 🌐 Network Troubleshooting

### Netshoot Plugin Usage

The netshoot plugin provides a comprehensive network troubleshooting toolkit with two main modes:

#### Interactive Troubleshooting
```bash
# Launch interactive shell with full netshoot toolkit
netshell                       # Standard pod shell
nethostshell                   # Host network access

# Debug existing pods or nodes
netdebug mypod                 # Debug specific pod
netdebug node/worker-1         # Debug specific node
kubectl netshoot debug mypod -- curl localhost:8080  # Run command in pod context
```

#### Quick One-Time Tests
```bash
# Basic connectivity tests
netping google.com             # Test external connectivity
netping my-service.default.svc.cluster.local  # Test internal service
netcurl -I https://kubernetes.default.svc.cluster.local  # HTTP connectivity
netwget -O- http://my-service:8080/health     # Download and test endpoints

# Service connectivity within cluster
netping my-service.my-namespace.svc.cluster.local
netcurl http://my-api:8080/metrics
nethttp GET my-service:8080/api/health        # Advanced HTTP testing
```

#### DNS Troubleshooting
```bash
# Basic DNS lookup
netnslookup kubernetes.default
netnslookup my-service.my-namespace.svc.cluster.local
nethost kubernetes.default.svc.cluster.local

# Advanced DNS queries with dig
netdig +short kubernetes.default.svc.cluster.local
netdig @8.8.8.8 google.com
netdig -x 10.96.0.1  # Reverse DNS lookup
netdig AAAA kubernetes.default  # IPv6 lookup

# Alternative DNS tools
netdrill kubernetes.default.svc.cluster.local  # Alternative to dig
netwhois google.com  # Domain information
```

#### Network Analysis
```bash
# Port scanning
netnmap -p 80,443,8080 my-service
netnmap -p 1-1000 10.96.0.1

# Connection testing
nettelnet my-service 8080
nettelnet kubernetes.default 443

# Socket and connection analysis
netss -tulpn                    # Show listening ports
netnetstat -rn                  # Show routing table
nettrace google.com             # Traceroute
```

#### Performance Testing
```bash
# HTTP performance and load testing
nethttp GET my-service:8080/api/health
nethttp --timeout=30 POST my-api:8080/data
netfortio load -c 10 -qps 100 -t 30s http://my-service:8080/  # Load testing

# Network performance testing
netiperf -c my-iperf-server -t 30        # TCP bandwidth test
netiperf -c my-iperf-server -u           # UDP test
netiperf_server                          # Start iperf server

# gRPC testing
netgrpcurl -plaintext my-grpc-service:9090 list
netgrpcurl -plaintext my-grpc-service:9090 my.package.Service/Method

# Speed testing
netspeedtest                             # Internet speed test
```

#### Packet Analysis
```bash
# Basic packet capture
nettcpdump -i eth0 -n
nettcpdump -i any host 10.96.0.1
nettcpdump -i eth0 port 80 -A

# Filtered captures
nettcpdump -i eth0 'tcp port 8080'
nettcpdump -i any 'icmp'
```

### Available Tools in Netshoot

The netshoot container includes 100+ network tools:

#### Basic Network Tools
- `ping`, `ping6` - Connectivity testing
- `traceroute`, `traceroute6` - Route tracing
- `mtr` - Network diagnostic tool
- `nmap` - Network exploration and security auditing
- `masscan` - Fast port scanner

#### HTTP/Web Tools
- `curl` - Transfer data to/from servers
- `wget` - File download utility
- `httpie` - Human-friendly HTTP client
- `ab` - Apache HTTP server benchmarking tool

#### DNS Tools
- `nslookup` - Query DNS servers
- `dig` - DNS lookup tool
- `host` - DNS lookup utility
- `dnsutils` - DNS utilities package

#### Network Analysis
- `tcpdump` - Packet analyzer
- `wireshark` - Network protocol analyzer (tshark)
- `netstat` - Network connections and routing tables
- `ss` - Socket statistics
- `lsof` - List open files and network connections

#### Performance Tools
- `iperf3` - Network bandwidth measurement
- `netperf` - Network performance measurement
- `bmon` - Bandwidth monitor
- `iftop` - Interface bandwidth usage

## 🔍 Troubleshooting

### Common Issues

#### 1. Krew Plugins Not Available
```bash
#NOTE SOME PLUGINS NOT AVAILABLE ON ARM64
# Check krew path
echo $PATH | grep krew

# Manually add krew to path
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```

#### 2. Netshoot Plugin Issues
```bash
# Verify netshoot installation
kubectl krew list | grep netshoot

# Reinstall if needed
kubectl krew uninstall netshoot
kubectl krew install netshoot

# Test basic functionality
kubectl netshoot -- ping 8.8.8.8
```

### Manual Tool Installation

If automatic installation fails, you can manually install tools:

```bash
# Reinstall specific tool
cd /workspaces/orc.showsite.infra
.devcontainer/scripts/post-create.sh

# Or install individual components
source .devcontainer/scripts/post-create.sh
install_kubectl
install_krew_and_plugins
setup_cli_completions
```

## 🎛 Customization

### Starship Configuration

Edit `~/.config/starship.toml` to customize the prompt:

```toml
# Example: Disable memory usage display
[memory_usage]
disabled = true

# Example: Change Kubernetes format
[kubernetes]
format = 'on [☸ $context($namespace)](blue) '
```

### Adding Custom Aliases

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Custom aliases
alias myalias='my-long-command'
alias kpods='kubectl get pods -o wide'
alias klogs='kubectl logs -f'
```

### Installing Additional Kubectl Plugins

```bash
# Search for plugins
kubectl krew search [term]

# Install new plugin
kubectl krew install [plugin-name]

# Update all plugins
kubectl krew upgrade
```

## 📊 Performance

### Container Specifications

- **Base Image**: Ubuntu 22.04 LTS
- **Architecture Support**: AMD64 and ARM64
- **Startup Time**: ~30-60 seconds (depending on downloads)
- **Disk Space**: ~2-3 GB after full setup
- **Memory Usage**: ~200-500 MB for tools and shell

### Optimization Features

- **Conditional Installation**: Tools only installed if not present
- **Architecture Detection**: Automatic binary selection for platform
- **Caching**: Docker layer caching for faster rebuilds
- **Background Downloads**: Parallel tool installation where possible

## 🔄 Updates and Maintenance

### Updating the Dev Container

1. **Rebuild Container**: VS Code Command Palette → "Dev Containers: Rebuild Container"
2. **Update Tools**: Tools automatically update to latest versions on rebuild
3. **Custom Updates**: Modify `post-create.sh` for additional tools or configurations

### Version Pinning

To pin specific tool versions, modify the installation functions in `post-create.sh`:

```bash
# Example: Pin terraform version
TERRAFORM_VERSION="1.6.0"  # Instead of latest
```

## 🤝 Contributing

### Adding New Tools

1. Create installation function in `post-create.sh`
2. Add to main installation sequence
3. Update validation script
4. Document in this README

### Modifying Shell Configuration

1. Update alias sections in `setup_shell_enhancements()`
2. Test with both ZSH and Bash
3. Update documentation

### Testing Changes

```bash
# Validate all functionality
.devcontainer/scripts/validate-setup.sh

# Test specific components
.devcontainer/scripts/test-completions.sh
.devcontainer/scripts/test-krew.sh
```

## 📚 References

- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Starship Prompt](https://starship.rs/)
- [Krew Plugin Manager](https://krew.sigs.k8s.io/)
- [Netshoot Network Troubleshooting](https://github.com/nicolaka/netshoot)
- [FluxCD Documentation](https://fluxcd.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
