HOMESHICK_REPO="$HOMESHICK_REPOS/homeshick/"

# Add functions
source "$HOMESHICK_REPO/homeshick.sh"

# Enable completion
fpath=($HOMESHICK_REPO/completions $fpath)
compinit

# Refresh local
homeshick refresh
