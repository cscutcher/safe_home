# Enhancements to wemux
export WEMUX_PASSWORD_PATH="$HOME/.wemux_pass.gpg"

function wemux_get_username(){
    pass show nx6/$(hostname)/wemux_username
    return $?
}

function wemux_update_password(){
    local WEMUX_USERNAME="$(wemux_get_username)"
    local NEW_PASSWORD="$(pwgen 20 -y1)"

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
}

function wemux_disable(){
    local WEMUX_USERNAME="$(wemux_get_username)"
    sudo passwd -l "$WEMUX_USERNAME"
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

    (
    echo "Connect with;"
    echo "ssh -p2222 ${WEMUX_USERNAME}@${ADDRESS}"
    echo ""
    echo "Password is '$WEMUX_PASSWORD'" ) | tee /dev/tty | xclip -sel clip -in
}
