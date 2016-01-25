# Setup askpass appropriately
if [ -z "$DISPLAY" ]; then
    unset SSH_ASKPASS
    unset SSLPASS
else
    if [ -z $SSLPASS ]; then
        export SSLPASS="ssh-ask-pass"
    fi
fi
