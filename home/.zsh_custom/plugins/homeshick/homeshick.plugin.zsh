HOMESHICK_REPO="$HOMESHICK_REPOS/homeshick/"

# Add functions
source "$HOMESHICK_REPO/homeshick.sh"

# Enable completion
fpath=($HOMESHICK_REPO/completions $fpath)
compinit

# Refresh local
if [ "$ENABLE_DEBUG_LOG" = false ]; then
    QUIET_ARG="--quiet"
else
    QUIET_ARG=""
fi
homeshick refresh $QUIET_ARG
