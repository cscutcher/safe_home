log "Checking GPG"
if which gpg 2>&1 >/dev/null; then
    log "Have GPG"
    if gpg -K | grep -q "$DEFAULT_PGP_KEY"; then
        log "Key installed"
        GPG_ARGS="$DEFAULT_PGP_KEY"
    else
        log "GPG installed but no key setup."
        GPG_ARGS=""
    fi
else
    log "GPG not installed!"
    GPG_ARGS=""
fi

log "Checking SSH key"
if [ -e "$HOME/.ssh/id_rsa" ]; then
    log "Found SSH key"
    SSH_ARGS="$HOME/.ssh/id_rsa"
else
    SSH_ARGS=""
fi

if [ -n "$GPG_ARGS" ]; then
    AGENTS="gpg,ssh"
else
    AGENTS="ssh"
fi

if [ -z "$DISPLAY" ]; then
    GUI_ARG="--nogui"
else
    GUI_ARG=""
fi

log "Setting up a keyring/keychain"
if hash keychain 2> /dev/null; then
    log "Found keychain in path"

    keychain --agents $AGENTS $SSH_ARGS $GPG_ARGS $GUI_ARG

    if [ -n "$SSH_ARGS" ]; then
        source $HOME/.keychain/$HOSTNAME-sh
    fi

    if [ -n "$GPG_ARGS" ]; then
        source $HOME/.keychain/$HOSTNAME-sh-gpg
    fi
else
    log "Unable to load a keyring!"
fi

if ( ! ssh-add -l | grep -q .ssh/id_rsa ) ; then
    ssh-add ~/.ssh/id_rsa
fi
