function gpg_available(){
    # Returns success if gpg is avalable
    log "Checking GPG"
    if which gpg 2>&1 >/dev/null; then
        log "Have GPG"
        return 0
    else
        log "GPG not installed!"
        return 1
    fi
}

function gpg_unlock_default_key(){
    # Unlock the default key by encrypted an empty string.
    if ! gpg_available; then
        log_error "GPG was unavailable."
    fi
    echo | gpg -s -u "$DEFAULT_PGP_KEY" >/dev/null
}

function get_ssh_keys(){
    # Find all SSH keys. At the moment this just looks for the obvious is_rsa
    local FOUND_KEY=1
    log "Finding ssh keys"
    if [ -e "$HOME/.ssh/id_rsa" ]; then
        log "Found SSH key: $HOME/.ssh/id_rsa"
        echo "$HOME/.ssh/id_rsa"
        FOUND_KEY=0
    fi
    return $FOUND_KEY
}

function load_ssh_keys(){
    # Load all known SSH keys
    for k in $(get_ssh_keys); do
        ssh-add $k
    done
}

function use_gpg_as_ssh_agent(){
    # Switch to GPG for SSH agent
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
      export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi
}

function start_gpg_agent(){
    # Start gpg agent and use for SSH agent
    log "Using GPG agent for SSH and GPG"

    if gpg_available; then

        if [ -z "$DISPLAY" ]; then
            GUI_ARG="--pinentry-program=/usr/bin/pinentry-curses"
        else
            GUI_ARG=""
        fi
        GPG_TTY=$(tty)
        export GPG_TTY
        gpg-agent --enable-ssh-support "$GUI_ARG"
        use_gpg_as_ssh_agent
    else
        log_error "GPG not available."
        return 1
    fi
}


function start_keychain(){
    # Starts keychain. If gpg agent is available use that for SSH
    local AGENTS
    local GUI_ARG

    if gpg_available; then
        AGENTS="gpg"
        GPG_TTY=$(tty)
        export GPG_TTY
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

        keychain --inherit any --agents $AGENTS $GUI_ARG

        if [ -n "$SSH_ARGS" ]; then
            source $HOME/.keychain/$HOSTNAME-sh
        fi

        if gpg_available; then
            source $HOME/.keychain/$HOSTNAME-sh-gpg
            # Try and use gpg for SSH
            use_gpg_as_ssh_agent
        fi
    else
        log "Unable to load a keyring!"
    fi
}

if [ -z ${SSH_AUTH_SOCK+x} ]; then
    log "No SSH_AUTH_SOCK"
else
    log "SSH_AUTH_SOCK already exists: $SSH_AUTH_SOCK"
fi
start_keychain
