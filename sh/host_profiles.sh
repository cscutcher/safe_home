# Load host specific profiles
HOST_PROFILE=$HOME/.profile.hosts.d/$HOSTNAME.profile
if [ -f $HOST_PROFILE ]; then
    log "Running $HOST_PROFILE"
    . $HOST_PROFILE
fi
