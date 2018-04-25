# Load override profile that should not be stored in homeshick
LOCAL_PROFILE="$HOME/.profile-local"
if [ -f $LOCAL_PROFILE ]; then
    log "Running $LOCAL_PROFILE"
  . $LOCAL_PROFILE
fi
