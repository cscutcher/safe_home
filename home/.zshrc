# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HOMESHICK_MAIN_RC="$HOME/.homesick/repos/safe_home/sh/rc.sh"
if [ -e $HOMESHICK_MAIN_RC ]; then
    emulate sh -c 'source $HOMESHICK_MAIN_RC'
else
    echo "ERROR NO HOMESHICK PROFILE: EXPECT CHAOS" 1>&2
fi

LOG_CONTEXT="zsh"
log_debug "Starting zshrc"

# Path to your oh-my-zsh installation.
export ZSH=$HOMESHICK_REPOS/oh-my-zsh

# zplug
# See https://github.com/zplug/zplug
export ZPLUG_HOME=$HOMESHICK_REPOS/zplug
source "${ZPLUG_HOME}/init.zsh"

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="powerlevel10k/powerlevel10k"

POWERLEVEL9K_COLOR_SCHEME='light'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context virtualenv dir dir_writable vi_mode root_indicator)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(vcs status background_jobs history time)
POWERLEVEL9K_VI_INSERT_MODE_STRING=""

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

# Threshold to notify when command completes
bgnotify_threshold=20
fgnotify_threshold=60

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    fix_colors
    fix_keys
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
    vi-mode
    nx6_bgnotify # Notify when long running commands finish
    pipenv # Pipenv auto completion
    history # Sync history on command execution & other useful stuff
    direnv # Like auotenv only better
)

# Zplug plugins
# See https://github.com/zplug/zplug
# zsh-autoenv overlaps a little with direnv.
# direnv has the advantage of being more secure and with a few more
# features, but zsh-autoenv is a little more flexible.
zplug "Tarrasch/zsh-autoenv"

# zplug check returns true if all packages are installed
# Therefore, when it returns false, run zplug install
if ! zplug check; then
    zplug install
fi

# source plugins and add commands to the PATH
zplug load

# User configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

log_debug "Looking for pre ohmyzsh scripts"
for f in $ZSH_CUSTOM/pre_ohmyzsh/**/*.zsh(N); do
    log_debug "     Sourcing $f"
    source "$f"
done

source $ZSH/oh-my-zsh.sh

# Is powerline installed
export POWERLINE_DIR=$(python -c 'import powerline; import os.path; print(os.path.dirname(powerline.__file__))')
if [[ $POWERLINE_DIR != "" ]]; then
    log_debug "Powerline installed at $POWERLINE_DIR"
else
    log_error "Powerline not installed."
fi

# Fuck
alias fuck='eval $(thefuck $(fc -ln -1))'

# Add ruby binaries to path
export GEM_BIN_DIRS=(~/.gem/ruby/*/bin)
export PATH="$PATH:${(j.:.)GEM_BIN_DIRS}"

# Other keybindings

# Rebind home to goto beginning of line. A habit I've not been able to break!
bindkey -M viins "${terminfo[khome]}" beginning-of-line
# Rebind end to goto end of line. A habit I've not been able to break!
bindkey -M viins "${terminfo[kend]}" end-of-line

# Bind ctrl-e to edit current line
bindkey -M viins "^E" edit-command-line

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
