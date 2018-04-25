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
    message=`cat`
    printf "%-20s :: %s\n" "$LOG_CONTEXT" "$message"  | interactive_output
}

function log
{
    echo $* | log_prefix_stdout
}

function log_error
{
    local RED='\033[0;31m'
    local NO_COLOR='\033[0m'

    ( echo -en "${RED}ERROR: "; echo -n "$*" ; echo -en "${NO_COLOR}" ) | log_prefix_stdout
}
