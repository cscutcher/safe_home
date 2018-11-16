# Enhancements to wemux
export WEMUX_PASSWORD_PATH="$HOME/.wemux_pass.gpg"

function wemux_get_username(){
    pass show nx6/$(hostname)/wemux_username
    return $?
}

function wemux_update_password(){
    local WEMUX_USERNAME="$(wemux_get_username)"
    local NEW_PASSWORD="$(pwgen 20 -n1)"

    ( echo ${WEMUX_USERNAME}:${NEW_PASSWORD} | sudo chpasswd ) || \
        ( echo "Failed to update wemux password" ; return 1 )

    # Update password on disk
    if [[ -e "$WEMUX_PASSWORD_PATH" ]]; then
        rm "$WEMUX_PASSWORD_PATH"
    fi
    gpg --batch --quiet \
        -u "$DEFAULT_PGP_KEY" -aeo "$WEMUX_PASSWORD_PATH" <<< "$NEW_PASSWORD"
}

function wemux_get_password(){
    gpg --batch --quiet --decrypt -o - "$WEMUX_PASSWORD_PATH"
}

function wemux_enable(){
    wemux_update_password
    local WEMUX_USERNAME="$(wemux_get_username)"
    if [[ -z "$WEMUX_USERNAME" ]]; then
        return 1
    fi
    if [[ -z "$1" ]]; then
        export WEMUX_SESSION_LENGTH="$1"
    else
        export WEMUX_SESSION_LENGTH="3600"
    fi
    echo "Wemux session length $WEMUX_SESSION_LENGTH"

    nohup sudo -n bash -c "\
        [[ -z "$WEMUX_USERNAME" ]] && exit 1; \
        sleep $WEMUX_SESSION_LENGTH; \
        passwd -l $WEMUX_USERNAME; \
        killall --user $WEMUX_USERNAME; \
        sleep 1; \
        killall --signal KILL --user $WEMUX_USERNAME " &
    tmux set -g lock-after-time 600
}

function wemux_status(){
    local WEMUX_USERNAME="$(wemux_get_username)"
    local ACCOUNT_LOCKED=1
    local LOGGED_IN=1

    if (sudo cat /etc/shadow | egrep -q "^$WEMUX_USERNAME:\!"); then
        echo "Wemux account locked"
        ACCOUNT_LOCKED=0
    else
        echo "Wemux account unlocked!"
        ACCOUNT_LOCKED=1
    fi

    if (users | grep -q "$WEMUX_USERNAME"); then
        echo "Wemux user logged in!"
        LOGGED_IN=0
    else
        echo "Wemux user logged out."
        LOGGED_IN=1
    fi
    return $(( ACCOUNT_LOCKED == 1 || LOGGED_IN == 0 ))
}

function wemux_disable(){
    local WEMUX_USERNAME="$(wemux_get_username)"
    sudo passwd -l "$WEMUX_USERNAME"
    sudo killall --user="$WEMUX_USERNAME"
    wemux_status && tmux set -g lock-after-time 0
}

function wemux_get_info(){
    local DEVICE="$1"

    if [[ -z $DEVICE ]]; then
        echo "Must specify a device"
        return 1
    fi

    local WEMUX_USERNAME="$(wemux_get_username)"
    local WEMUX_PASSWORD="$(wemux_get_password)"

    local ADDRESS=""
    case "$DEVICE" in
        ipv6)
            ADDRESS="$(ip -6 addr | egrep -o '2001:[a-f0-9:]*')"
            ;;
        hostname)
            ADDRESS="$(hostname)"
            ;;
        *)
            ADDRESS=$(nmcli -f IP4.ADDRESS d show $DEVICE | egrep -o "[0-9.]+/[0-9]*$" | egrep -o "^[0-9.]+")
            ;;
    esac

    local XCLIP=""
    if [[ -z $DISPLAY ]]; then
        XCLIP="cat"
    else
        XCLIP="xclip -sel clip -in"
    fi

    (
    echo "Connect with;"
    echo "ssh -p2222 ${WEMUX_USERNAME}@${ADDRESS}"
    echo ""
    echo "Password is '$WEMUX_PASSWORD'"
    echo ""
    echo "Expect the following host keys;"
    ssh-keyscan "$ADDRESS" 2>/dev/null
    ) | tee /dev/tty | eval $XCLIP
}

function wemux_lockout(){
    wemux_update_password
    tmux lock-session
}
