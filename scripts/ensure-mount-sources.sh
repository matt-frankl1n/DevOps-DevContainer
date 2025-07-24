#!/bin/bash

# This cross-platform script ensures that the source mount points in devcontainer.json exist on the host.

echo "Ensuring mount points exist..."

# Create mount directories based on OS
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WINDIR" ]]; then
    # Windows
    echo "Detected Windows environment"
    if command -v powershell.exe &> /dev/null; then
        powershell.exe -Command "New-Item -ItemType Directory -Force -Path \$env:USERPROFILE\.kube, \$env:USERPROFILE\.minikube | Out-Null"
    else
        mkdir -p "$USERPROFILE/.kube" "$USERPROFILE/.minikube" 2>/dev/null || true
    fi
else
    # macOS/Linux
    echo "Detected Unix-like environment"
    mkdir -p "$HOME/.kube" "$HOME/.minikube" 2>/dev/null || true
fi

echo "Mount points ensured successfully"
