export HOSTNAME=$( trim $(cat /etc/hostname) )

# set PATH so it includes host specific private bin if it exists
export PATH="$PATH:$HOME/bin/:$HOME/bin/$HOSTNAME:$HOME/.local/bin"

# Try and find path to dropbox
if [ -x "$HOME/bin/get_dropbox_folder.sh" ] ; then
    export DROPBOX=$($HOME/bin/get_dropbox_folder.sh)
else
    log_error "Couldn't attempt discovery of dropbox folder"
fi

#Try and find boxcryptor
if [ $DROPBOX ] ; then
    BOXCRYPTOR_SRC="$DROPBOX/BoxCryptor"
    if [ -d $BOXCRYPTOR_SRC ] ; then
        export BOXCRYPTOR_SRC
        export BOXCRYPTOR="$HOME/BoxCryptor"
    else
        log_error "Couldn't discover Boxcryptor"
    fi
fi
