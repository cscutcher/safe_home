HOMESHICK_MAIN_PROFILE="$HOME/.homesick/repos/safe_home/sh/profile.sh"
if [ -e $HOMESHICK_MAIN_PROFILE ]; then
    source $HOMESHICK_MAIN_PROFILE
else
    echo "ERROR NO HOMESHICK PROFILE: EXPECT CHAOS" 1>&2
fi
