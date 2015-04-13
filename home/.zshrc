# NINEBYSIX customise bashrc
if [ ! -e $HOME/.homesick/repos/safe_home/sh/profile_vars.sh ]; then
    echo "ERROR NO PROFILE VARS: EXPECT CHAOS" 1>&2
fi
source $HOME/.homesick/repos/safe_home/sh/profile_vars.sh
source $HOME_SH_LIBS/logging_functions.sh

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
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOMESICK_REPOS/safe_home/zsh_custom

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    git-extras
    pip
    fabric
    debian
    docker
    homeshick
    command-not-found 
    common-aliases
    jsontools # Adds pp_json is_json urlencode_json urldecode_json
    virtualenvwrapper
    dirhistory # Alt-right alt-left to go back forth between dir
    wd # wd add some_dir ; wd some_dir
    mosh
    colorize # Syntax highlighting type cat
)

# User configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh


# Aliases shared with bash
source $HOME_SH_LIBS/aliases.sh
    
# Is powerline installed
POWERLINE_DIR=$(python -c 'import powerline; import os.path; print os.path.dirname(powerline.__file__)')
if [[ $POWERLINE_DIR != "" ]]; then
    log "Powerline installed"
    powerline-daemon -q
    . $POWERLINE_DIR/bindings/zsh/powerline.zsh
else
    log "Powerline not installed. Using fallback"
fi
