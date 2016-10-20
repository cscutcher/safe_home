log "Checking GPG"
if which gpg 2>&1 >/dev/null; then
    log "Have GPG"
    function gpg_activate_default_key(){
        echo | gpg -s -u "$DEFAULT_PGP_KEY" >/dev/null
    }
    GPG_ENABLED=0
else
    log "GPG not installed!"
    GPG_ENABLED=1
fi

log "Checking SSH key"
if [ -e "$HOME/.ssh/id_rsa" ]; then
    log "Found SSH key"
    SSH_ARGS="$HOME/.ssh/id_rsa"
else
    SSH_ARGS=""
fi

if [ $GPG_ENABLED -eq 0 ]; then
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

    keychain --agents $AGENTS $SSH_ARGS $GUI_ARG

    if [ -n "$SSH_ARGS" ]; then
        source $HOME/.keychain/$HOSTNAME-sh
    fi

    if [ $GPG_ENABLED -eq 0 ]; then
        source $HOME/.keychain/$HOSTNAME-sh-gpg
    fi
else
    log "Unable to load a keyring!"
fi

if ( ! ssh-add -l | grep -q .ssh/id_rsa ) ; then
    ssh-add ~/.ssh/id_rsa
fi
