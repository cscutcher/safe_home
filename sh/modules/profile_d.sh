# Load any profiles in ~/.profile.d
if [ -d $HOME/.profile.d ]; then
    log "Looking for profile.d"
    for f in *.profile; do
        log "Loading profile: $f"
        source $f
    done
fi
