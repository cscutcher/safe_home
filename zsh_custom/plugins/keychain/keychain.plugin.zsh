function gpg_key_good {
    if gpg --list-secret-keys 2> /dev/null | grep $DEFAULT_PGP_KEY &>/dev/null
    then
        log "GPG key $DEFAULT_PGP_KEY installed"

        if ! pgrep gpg-agent &> /dev/null; then
            log "! NO GPG AGENT !"
            return 1
        fi

        # Make sure key is ok
        while ! echo "test" | gpg -u $DEFAULT_PGP_KEY -s -q --batch --use-agent &> /dev/null;
        do
            log "GPG password bad"
            echo "test" | gpg -u $DEFAULT_PGP_KEY -s --use-agent > /dev/null
        done
    fi

    return 0
}


log "Setting up a keyring/keychain"
if hash keychain 2> /dev/null; then
    log "Found keychain"
    if [ -z "$DISPLAY" ]; then 
        GUI_ARG="--nogui"
    else
        GUI_ARG=""
    fi
    #keychain $HOME/.ssh/id_rsa $DEFAULT_PGP_KEY $GUI_ARG
    # having problems with key loading so commenting this out for now
    keychain
    source $HOME/.keychain/$HOSTNAME-sh
    source $HOME/.keychain/$HOSTNAME-sh-gpg

    #gpg_key_good
else
    log "Unable to load a keyring!"
fi
