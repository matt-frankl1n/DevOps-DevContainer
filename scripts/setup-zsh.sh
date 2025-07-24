#!/bin/bash

echo "=== ZSH Setup Verification ==="
echo ""
echo "Note: ZSH is configured as the default shell in this dev container."
echo "This script verifies and ensures all ZSH configurations are properly set up."
echo ""

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "ZSH is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y zsh
fi

# Create zshrc if it doesn't exist
if [ ! -f ~/.zshrc ]; then
    echo "Creating ~/.zshrc..."
    touch ~/.zshrc
fi

# Set zsh as default shell for the user
if [ "$SHELL" != "/bin/zsh" ]; then
    echo "Setting zsh as default shell..."
    sudo chsh -s /bin/zsh $(whoami)
    echo "✓ ZSH set as default shell"
    echo "  Note: You'll need to restart your terminal or container for this to take effect"
else
    echo "✓ ZSH is already the default shell"
fi

# Ensure starship is configured for zsh
if command -v starship &> /dev/null; then
    if ! grep -q "starship init zsh" ~/.zshrc; then
        echo "Configuring starship for zsh..."
        echo 'eval "$(starship init zsh)"' >> ~/.zshrc
        echo "✓ Starship configured for zsh"
    else
        echo "✓ Starship already configured for zsh"
    fi
fi

# Ensure zsh completions are configured
if [ -d ~/.zsh_completion.d ]; then
    if ! grep -q "zsh_completion.d" ~/.zshrc; then
        echo "Configuring zsh completions..."
        cat >> ~/.zshrc << 'EOF'

# Load custom zsh completions
if [ -d ~/.zsh_completion.d ]; then
    fpath=(~/.zsh_completion.d $fpath)
    autoload -U compinit
    compinit
fi

EOF
        echo "✓ ZSH completions configured"
    else
        echo "✓ ZSH completions already configured"
    fi
fi

# Add useful aliases if not already present
if ! grep -q "# Useful aliases for development" ~/.zshrc; then
    echo "Adding useful aliases to zsh..."
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
alias kns='kubectl config set-context --current --namespace'
alias kctx='kubectl config use-context'

# Flux aliases
alias fget='flux get'
alias flog='flux logs'
alias freconcile='flux reconcile'

EOF
    echo "✓ Useful aliases added to zsh"
else
    echo "✓ Useful aliases already configured for zsh"
fi

echo ""
echo "=== ZSH Verification Complete ==="
echo ""
echo "ZSH is configured as the default shell with:"
echo "  ✓ Starship prompt"
echo "  ✓ CLI completions for kubectl, helm, flux, talosctl"
echo "  ✓ Useful aliases for development"
echo ""
echo "New terminals will automatically use ZSH."
echo "To switch to ZSH in the current terminal, run: zsh"
