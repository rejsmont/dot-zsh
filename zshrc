# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export TERM="xterm-256color"
export COLORFGBG="7;0"

function zsh_install() {
    echo "Installing antigen..."
    mkdir -p ~/.zsh/frameworks
    curl -L git.io/antigen > .zsh/frameworks/antigen.zsh
    echo "Installing iTerm2 integration..."
    curl -L https://iterm2.com/shell_integration/zsh -o ~/.zsh/frameworks/iterm2_shell_integration.zsh
    echo "Installing custom scripts..."
    local TAR=$(tar --version)
    if [[ ${TAR#'tar (GNU tar)'} != ${TAR} ]]; then
        curl -L https://git.io/rejsmont.zsh.tar.gz | tar -zxvC ~/.zsh --strip-components 2 --wildcards \*/scripts/\*.zsh
    elif [[ $(gtar >/dev/null 2>&1; echo $?) ]]; then
        curl -L https://git.io/rejsmont.zsh.tar.gz | gtar -zxvC ~/.zsh --strip-components 2 --wildcards \*/scripts/\*.zsh
    else
        local TS=$(date +%s)
        mkdir -p /tmp/zsh_install_$TS
        curl -L https://git.io/rejsmont.zsh.tar.gz | gtar -zxvC /tmp/zsh_install
        mv /tmp/zsh_install/*/scripts/*.zsh ~/.zsh/
        rm -rf /tmp/zsh_install_$TS
    fi
}

function zsh_update() {
    echo "Updating antigen..."
    curl -L git.io/antigen > .zsh/frameworks/antigen.zsh
    antigen update
    echo "Updating iTerm2 integration..."
    curl -L https://iterm2.com/shell_integration/zsh -o ~/.zsh/frameworks/iterm2_shell_integration.zsh
    echo "Updating custom scripts..."
    local TAR=$(tar --version)
    if [[ ${TAR#'tar (GNU tar)'} != ${TAR} ]]; then
        curl -L https://git.io/rejsmont.zsh.tar.gz | tar -zxvC ~/.zsh --strip-components 2 --wildcards \*/scripts/\*.zsh
    elif [[ $(gtar >/dev/null 2>&1; echo $?) ]]; then
        curl -L https://git.io/rejsmont.zsh.tar.gz | gtar -zxvC ~/.zsh --strip-components 2 --wildcards \*/scripts/\*.zsh
    else
        local TS=$(date +%s)
        mkdir -p /tmp/zsh_install_$TS
        curl -L https://git.io/rejsmont.zsh.tar.gz | gtar -zxvC /tmp/zsh_install
        mv /tmp/zsh_install/*/scripts/*.zsh ~/.zsh/
        rm -rf /tmp/zsh_install_$TS
    fi
}

if [[ ! -d ~/.zsh ]]; then
    zsh_install
fi

ADOTDIR="$HOME/.zsh/antigen"

source ~/.profile
source ~/.zsh/frameworks/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    source ~/.zsh/frameworks/iterm2_shell_integration.zsh
    antigen bundle iterm2
fi

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle pip
antigen bundle command-not-found
[[ `uname` == "Darwin" ]] && antigen bundle osx

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen theme romkatv/powerlevel10k

# Tell Antigen that you're done.
if [[ `uname` == "Darwin" && `id -u` == "0" ]]; then
    antigen apply > /dev/null 2>&1
else
    antigen apply
fi

if [[ -d ~/.zsh ]]; then
    for script in `echo ~/.zsh/*(.)`; do
        source $script
    done
fi
