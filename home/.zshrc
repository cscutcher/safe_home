# NINEBYSIX customise bashrc
LOG_CONTEXT="zsh"
log "Starting zshrc"

# Path to your oh-my-zsh installation.
export ZSH=$HOMESICK_REPOS/oh-my-zsh


# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# NOTE: I already have another method for updating repo
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.zsh_custom

# Disable auto venc on cd
DISABLE_VENV_CD=1

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    fix_colors
    fix_keys
    git
    git-extras
    pip
    fabric
    debian
    docker
    keychain
    homeshick
    command-not-found
    common-aliases
    jsontools # Adds pp_json is_json urlencode_json urldecode_json
    virtualenvwrapper
    dirhistory # Alt-right alt-left to go back forth between dir
    wd # wd add some_dir ; wd some_dir
    mosh
    colorize # Syntax highlighting type cat
    askpass
    git-config-d
)

# User configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"


log "Looking for pre ohmyzsh scripts"
for f in $ZSH_CUSTOM/pre_ohmyzsh/**/*.zsh(N); do
    log "     Sourcing $f"
    source "$f"
done

source $ZSH/oh-my-zsh.sh

# Aliases shared with bash
source $HOME_SH_LIBS/aliases.sh

# Is powerline installed
export POWERLINE_DIR=$(python -c 'import powerline; import os.path; print(os.path.dirname(powerline.__file__))')
if [[ $POWERLINE_DIR != "" ]]; then
    log "Powerline installed"
    powerline-daemon -q
    . $POWERLINE_DIR/bindings/zsh/powerline.zsh
else
    log "Powerline not installed. Using fallback"
fi

# Fuck
alias fuck='eval $(thefuck $(fc -ln -1))'

# Add ruby binaries to path
export GEM_BIN_DIRS=(~/.gem/ruby/*/bin)
export PATH="$PATH:${(j.:.)GEM_BIN_DIRS}"
