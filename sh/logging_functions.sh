function interactive_output
{
    if [[ $- =~ "i" ]]
    then
        cat >> /dev/stderr
    else
        cat > /dev/null
    fi
}

function log_prefix_stdout
{
    formatted=`printf "%-10s" $LOG_CONTEXT`
    sed -e "s/^/$formatted :: /" | interactive_output
}

function log
{
    echo $* | log_prefix_stdout
}

function log_error
{
    log "ERROR: $*" 1>&2
}
