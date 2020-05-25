# TODO: Move to common location
function check_packages(){
    for p in "$@"; do
        if ! pacman -Q "$p" > /dev/null 2>&1; then
            log_error pacman -Q "$p"
        fi
    done
}

check_packages \
    nerd-fonts-meslo
