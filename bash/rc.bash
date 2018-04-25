# NINEBYSIX customise bashrc
HOMESHICK_MAIN_RC="$HOME/.homesick/repos/safe_home/sh/rc.sh"
if [ -e $HOMESHICK_MAIN_RC ]; then
    source $HOMESHICK_MAIN_RC
else
    echo "ERROR NO HOMESHICK PROFILE: EXPECT CHAOS" 1>&2
fi

LOG_CONTEXT="bashrc"
log "Starting global bashrc"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=4000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    # Is powerline installed
    export POWERLINE_DIR=$(python -c 'import powerline; import os.path; print(os.path.dirname(powerline.__file__))')
    if [[ $POWERLINE_DIR != "" ]]; then
        log "Powerline installed"
        powerline-daemon -q
        . $POWERLINE_DIR/bindings/bash/powerline.sh
        _local_ps1() {
            PS1="$PS1\n\[\033[0;35m\][#\#][!\!]\$ \[\033[0m\]"
        }
        PROMPT_COMMAND="${PROMPT_COMMAND}"$'\n_local_ps1'
    else
        log "Powerline not installed. Using fallback"
        PS1="\n\[\033[1;34m\][${debian_chroot:+($debian_chroot)}\u@\h:\w]\n\[\033[0;35m\][#\#][!\!]\$ \[\033[0m\]"
    fi
else
	PS1="\n[${debian_chroot:+($debian_chroot)}\u@\h:\w]\n[#\#][!\!]\$ "
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

#############################################################################
# Above this point try and stick as much as possible to ubuntu default
#############################################################################
log "Guess \$TERM. \$COLORTERM is $COLORTERM"
if [ "$COLORTERM" == "gnome-terminal" ] || [ "$COLORTERM" == "xfce4-terminal" ]
then
    # Using xterm-256 as gnome-terminal doesn't properly advertise support
    export TERM=xterm-256color
elif [ "$COLORTERM" == "rxvt-xpm" ]
then
    export TERM=rxvt-256color
fi
log "\$TERM is $TERM"

log "Aliases and exports"
#Debian Stuff
export DEBFULLNAME='Chris Scutcher'
export DEBEMAIL='chris.scutcher@ninebysix.co.uk'

#Virtualenv wrapper
log "Set up virtualenv"

if function_exists mkvirtualenv
then
    log "virtualenvwrapper already installed"
else
    LOCAL_VIRTUALENVWRAPPER="/usr/local/bin/virtualenvwrapper.sh"
    if [ -f $LOCAL_VIRTUALENVWRAPPER ]; then
        log "Loading virtualenv wrapper from $LOCAL_VIRTUALENVWRAPPER"
        . $LOCAL_VIRTUALENVWRAPPER
    else
        USER_LOCAL_VIRTUALENVWRAPPER="$HOME/.local/bin/virtualenvwrapper.sh"
        if [ -f $USER_LOCAL_VIRTUALENVWRAPPER ]; then
            log "Loading virtualenv wrapper from $USER_LOCAL_VIRTUALENVWRAPPER"
            . $USER_LOCAL_VIRTUALENVWRAPPER
        else
            log "Couldn't load virtualenv wrapper"
        fi
    fi
fi

if function_exists mkvirtualenv
then
    export WORKON_HOME=$HOME/.virtualenvs
    if [ $DROPBOX ]; then
        export PROJECT_HOME=$DROPBOX/programming-projects
    else
        export PROJECT_HOME=$HOME/virtualenv
    fi
    log "Successfully setup virtualenvwrapper"
fi

log "Homeschick"
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
homeshick --quiet --batch refresh

#Add FabFiles
log "Setup fabfiles"
export FABFILES="$HOME/.fabfile.d/"
HOST_FABFILE="$FABFILES/$HOSTNAME"
COMMON_FABFILE="$FABFILES/common"
if [ -x $HOST_FABFILE ]; then
    export FABFILE=$HOST_FABFILE
else
    export FABFILE=$COMMON_FABFILE
fi
alias hfab="fab --fabfile=$FABFILE"


#Completion for fabfiles
_fab()
{
    local cur
    COMPREPLY=()
    # Variable to hold the current word
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Build a list of the available tasks using the command 'fab -l'
    local tags=$(fab -l 2>/dev/null | grep "^ " | awk '{print $1;}')

    # Generate possible matches and store them in the
    # array variable COMPREPLY
    COMPREPLY=($(compgen -W "${tags}" $cur))
}
_hfab()
{
    local cur
    COMPREPLY=()
    # Variable to hold the current word
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Build a list of the available tasks using the command 'fab -l'
    local tags=$(hfab -l 2>/dev/null | grep "^ " | awk '{print $1;}')

    # Generate possible matches and store them in the
    # array variable COMPREPLY
    COMPREPLY=($(compgen -W "${tags}" $cur))
}

# Assign the auto-completion function _fab for our command fab.
complete -F _fab fab
complete -F _hfab hfab

#Host specific configs
HOST_BASHRC=$HOME/.bashrc.hosts.d/$HOSTNAME.bashrc
if [ -f $HOST_BASHRC ]; then
    log "Running $HOST_BASHRC"
    . $HOST_BASHRC
fi

#Local
LOCAL_BASHRC="$HOME/.bashrc-local"
if [ -f $LOCAL_BASHRC ]; then
    log "Running $LOCAL_BASHRC"
  . $LOCAL_BASHRC
fi
