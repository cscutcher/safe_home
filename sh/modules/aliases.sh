alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias apti="sudo aptitude install"
alias aptis="aptitude search"
alias halt="sudo halt"
alias reboot="sudo reboot"
alias o="gnome-open"
ls /usr/bin/trash &> /dev/null || alias trash="trash-put"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias oct_perms='stat -c "%a %n"'

# Use nvim if available
if command -v nvim > /dev/null 2>&1; then
    alias vim='nvim'
fi
