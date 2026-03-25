#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# New Mac Setup Script
# Generated from existing machine on 2026-03-25
#
# Usage:
#   ./setup-new-mac.sh
#
# This script is idempotent — safe to re-run if something fails partway.
###############################################################################

info()  { printf "\n\033[1;34m→ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }

###############################################################################
# Xcode Command Line Tools
# If full Xcode.app is installed, point xcode-select at it.
# Otherwise install standalone CLT via softwareupdate.
###############################################################################
info "Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    if [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
        info "Full Xcode.app found — switching xcode-select to use it..."
        sudo /usr/bin/xcode-select --switch /Applications/Xcode.app/Contents/Developer
        sudo xcodebuild -license accept 2>/dev/null || true
        ok "xcode-select pointed at Xcode.app"
    else
        info "Installing Xcode Command Line Tools via softwareupdate..."
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        CLT_PACKAGE=$(softwareupdate -l 2>/dev/null \
            | grep -o ".*Command Line Tools.*" \
            | grep -v "^\\*" \
            | sed 's/^[[:space:]]*//' \
            | sort -V \
            | tail -1)
        if [ -n "$CLT_PACKAGE" ]; then
            softwareupdate -i "$CLT_PACKAGE" --verbose
            rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        else
            rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
            warn "Could not find CLT package via softwareupdate — falling back to xcode-select"
            xcode-select --install
            echo "Press Enter after Xcode CLI tools finish installing..."
            read -r
        fi
        ok "Xcode CLI tools installed"
    fi
else
    ok "Xcode CLI tools already installed"
fi

###############################################################################
# Homebrew
###############################################################################
info "Installing Homebrew..."
if ! command -v brew &>/dev/null; then
    # Homebrew's installer fails when only full Xcode.app is present (no standalone CLT).
    # Download, patch the CLT check to recognise Xcode.app, then run.
    BREW_INSTALLER="$(mktemp)"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "${BREW_INSTALLER}"

    # If full Xcode.app exists, make should_install_command_line_tools() return early
    if [ -e "/Applications/Xcode.app/Contents/Developer/usr/bin/git" ]; then
        sed -i '' '/^should_install_command_line_tools() {/,/^}/ {
            /return 1/! {
                /^should_install_command_line_tools() {/ a\
\  # Full Xcode.app detected — skip standalone CLT install\
\  if [[ -e "/Applications/Xcode.app/Contents/Developer/usr/bin/git" ]]; then return 1; fi
            }
        }' "${BREW_INSTALLER}"
    fi

    NONINTERACTIVE=1 /bin/bash "${BREW_INSTALLER}"
    rm -f "${BREW_INSTALLER}"

    eval "$(/opt/homebrew/bin/brew shellenv)"

    if ! command -v brew &>/dev/null; then
        warn "Homebrew installation failed — please install manually and re-run"
        exit 1
    fi
    ok "Homebrew installed"
else
    ok "Homebrew already installed"
fi

###############################################################################
# Homebrew Taps
###############################################################################
info "Adding Homebrew taps..."
TAPS=(
    aws/tap
    azure/kubelogin
    coursier/formulas
    hashicorp/tap
    hidetatz/tap
    homebrew/services
    int128/kubelogin
    johanhaleby/kubetail
    mutagen-io/mutagen
    warrensbox/tap
)

for tap in "${TAPS[@]}"; do
    brew tap "$tap" 2>/dev/null || warn "Failed to tap $tap"
done
ok "Taps configured"

###############################################################################
# Homebrew Formulae (core tools & libraries)
###############################################################################
info "Installing Homebrew formulae..."
FORMULAE=(
    # Version control & git
    gh

    # Languages & runtimes
    go
    node
    php
    composer
    python@3.12
    python@3.13
    pyenv
    pyenv-virtualenv
    chruby
    ruby-install
    coursier
    sbt
    openjdk
    openjdk@17
    openjdk@21

    # Cloud & infrastructure
    aws-sam-cli
    terraform
    tfenv
    tflint
    vault
    helm
    kubernetes-cli
    kube-ps1
    kubelogin
    kubetail
    minikube
    argo

    # Version switchers
    tfswitch
    tgswitch

    # Databases & data
    redis
    mongosh
    libpq
    parquet-cli

    # Protocol buffers & gRPC
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    grpcurl

    # Shell
    bash

    # General CLI tools
    jq
    fzf
    grep
    coreutils
    curl
    yarn
    pipenv
    black
    mypy
    ipython
    jupyterlab
    pandoc

    # Build tools
    autoconf
    automake
    libtool
    m4
    bison
    pkg-config

    # Security
    gnupg

    # Adobe / JFrog
    jfrog-cli

    # Testing
    jmeter
    k6

    # Mutagen (file sync)
    mutagen
)

for formula in "${FORMULAE[@]}"; do
    brew install "$formula" 2>/dev/null || warn "Failed to install $formula"
done
ok "Formulae installed"

###############################################################################
# Homebrew Casks (GUI applications)
###############################################################################
info "Installing Homebrew casks..."
CASKS=(
    git-credential-manager
    insomnia
    snowflake-snowsql
)

for cask in "${CASKS[@]}"; do
    brew install --cask "$cask" 2>/dev/null || warn "Failed to install cask $cask"
done
ok "Casks installed"

###############################################################################
# Oh My Zsh
###############################################################################
info "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    ok "Oh My Zsh already installed"
fi

# Custom plugins
info "Installing Oh My Zsh custom plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    ok "zsh-syntax-highlighting already installed"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-tgswitch" ]; then
    git clone https://github.com/ptavares/zsh-tgswitch.git "$ZSH_CUSTOM/plugins/zsh-tgswitch"
else
    ok "zsh-tgswitch already installed"
fi

# zsh-tfswitch plugin (check if available or create a basic one)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-tfswitch" ]; then
    warn "zsh-tfswitch plugin — you may need to install this manually"
    warn "Check: https://github.com/ptavares/zsh-tfswitch"
    git clone https://github.com/ptavares/zsh-tfswitch.git "$ZSH_CUSTOM/plugins/zsh-tfswitch" 2>/dev/null || true
fi

###############################################################################
# NVM (Node Version Manager)
###############################################################################
info "Installing NVM..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
    ok "NVM already installed"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

info "Installing Node versions via NVM..."
nvm install 20.14.0
nvm alias default 20.14.0
nvm use default
ok "Node v20.14.0 set as default"

###############################################################################
# Pyenv Python Versions
###############################################################################
info "Setting up pyenv..."
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null || true

info "Installing Python versions via pyenv..."
pyenv install -s 3.13.11
pyenv install -s 3.10.12
pyenv install -s 3.9.16
pyenv global 3.13.11
ok "Python versions installed, 3.13.11 set as global"

###############################################################################
# Ruby via chruby + ruby-install
###############################################################################
info "Installing Ruby 3.1.3..."
if [ ! -d "$HOME/.rubies/ruby-3.1.3" ]; then
    ruby-install ruby 3.1.3
else
    ok "Ruby 3.1.3 already installed"
fi

###############################################################################
# Go tools
###############################################################################
info "Installing Go tools..."
go install golang.org/x/tools/cmd/godoc@latest 2>/dev/null || true
go install golang.org/x/tools/gopls@latest 2>/dev/null || true
go install github.com/golang/mock/mockgen@latest 2>/dev/null || true
go install honnef.co/go/tools/cmd/staticcheck@latest 2>/dev/null || true
go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest 2>/dev/null || true
ok "Go tools installed"

###############################################################################
# Rust / Cargo
###############################################################################
info "Installing Rust..."
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    ok "Rust already installed"
fi

###############################################################################
# SDKMAN (Java SDK manager)
###############################################################################
info "Installing SDKMAN..."
if [ ! -d "$HOME/.sdkman" ]; then
    BREW_BASH="$(brew --prefix)/bin/bash"
    if [ -x "$BREW_BASH" ]; then
        curl -s "https://get.sdkman.io" | "$BREW_BASH"
    else
        warn "Homebrew bash not found — SDKMAN requires Bash 4+; skipping"
    fi
else
    ok "SDKMAN already installed"
fi

###############################################################################
# Krew (kubectl plugin manager)
###############################################################################
info "Installing Krew..."
if [ ! -d "$HOME/.krew" ]; then
    (
        set -x; cd "$(mktemp -d)" &&
        OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
        ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')" &&
        KREW="krew-${OS}_${ARCH}" &&
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
        tar zxvf "${KREW}.tar.gz" &&
        ./"${KREW}" install krew
    )
else
    ok "Krew already installed"
fi

###############################################################################
# Utility directories
###############################################################################
info "Creating utility directories..."
mkdir -p "$HOME/.bin"
mkdir -p "$HOME/.zsh/completion"
mkdir -p "$HOME/go/bin"


###############################################################################
# fzf key bindings
###############################################################################
info "Installing fzf key bindings..."
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true

###############################################################################
# Done
###############################################################################
echo ""
echo "============================================="
echo "  Setup complete!"
echo "============================================="
echo ""
