# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="nebirhos"

fpath=(
  ~/.zsh/completion
  $fpath
)
autoload -Uz compinit && compinit -i

plugins=(
  git
  z
  dotenv
  zsh-syntax-highlighting
  zsh-tgswitch
  zsh-tfswitch
)

source $ZSH/oh-my-zsh.sh

# Keypad bindings
bindkey -s "^[Op" "0"
bindkey -s "^[On" "."
bindkey -s "^[OM" "^M"
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"
bindkey -s "^[OX" "="

export PATH="/bin:$PATH"

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# protoc / gRPC
export PATH="/opt/homebrew/opt/protobuf/bin:$PATH"

# libpq (keg-only)
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# golang
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH="$GOBIN:$PATH"
# Uncomment and update if you need a specific Go version:
# export GOROOT=$(go1.22.0 env GOROOT)
# export PATH="$GOROOT/bin:$PATH"

# chruby
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.3

# aliases
source ~/.aka

source "/usr/local/opt/kube-ps1/share/kube-ps1.sh" 2>/dev/null || \
  source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh" 2>/dev/null || true
PS1='$(kube_ps1)'$PS1

# kubectl completion
source <(kubectl completion zsh)
alias kubectl=kubecolor
compdef kubecolor=kubectl

export PATH="$PATH:$HOME/.composer/vendor/bin"

# openssl from brew
export PATH="/opt/homebrew/opt/openssl/bin:$PATH"

# make (newer version)
PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# kubeconfig
export KUBECONFIG="$HOME/.kube/kubeconfig.yaml"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'

# nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# tgswitch and tfswitch install path
export PATH=$PATH:$HOME/.bin

load-tgswitch() {
  local tgswitchrc_path=".tgswitchrc"
  if [ -f "$tgswitchrc_path" ]; then
    tgswitch
  fi
}
add-zsh-hook chpwd load-tgswitch
load-tgswitch

load-tfswitch() {
  local tfswitchrc_path=".tfswitchrc"
  if [ -f "$tfswitchrc_path" ]; then
    tfswitch
  fi
}
add-zsh-hook chpwd load-tfswitch
load-tfswitch

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

. "$HOME/.local/bin/env" 2>/dev/null || true
