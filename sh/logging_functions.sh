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
    local RED='\033[0;31m'
    local NO_COLOR='\033[0m'

    log "${RED}ERROR: $*${NO_COLOR}"
}
