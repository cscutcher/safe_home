# Load any profiles in ~/.profile.d
if [ -d $HOME/.profile.d ]; then
    log_debug "Looking for profile.d"
    for f in `find -L $HOME/.profile.d -name '*.profile' -type f -readable`; do
        log_debug "Loading profile: $f"
        source $f
    done
fi
