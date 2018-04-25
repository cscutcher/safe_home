HOMESHICK_MAIN_BASH="$HOME/.homesick/repos/safe_home/bash/rc.bash"
if [ -e $HOMESHICK_MAIN_BASH ]; then
    source $HOMESHICK_MAIN_BASH
else
    echo "ERROR NO HOMESHICK PROFILE: EXPECT CHAOS" 1>&2
fi
