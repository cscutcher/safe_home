LOG_CONTEXT="rc"

# Load logging helpers
if [ -e $HOMESHICK_MAIN_SH/modules/logging_functions.sh ]; then
    source $HOMESHICK_MAIN_SH/modules/logging_functions.sh
    log_debug "Loaded logging."
else
    echo "ERROR NO LOGGING: EXPECT CHAOS" 1>&2
fi

# Load other helpers
for sh_module in \
        common_sh_functions \
        aliases \
    ; do
    sh_module_full="${HOMESHICK_MAIN_SH}modules/${sh_module}.sh"
    if [ -e $sh_module_full ]; then
        OLD_LOG_CONTEXT="$LOG_CONTEXT"
        log_debug "Loading: $sh_module"
        LOG_CONTEXT="$sh_module"
        source $sh_module_full
        LOG_CONTEXT="$OLD_LOG_CONTEXT"
    else
        log_error "$sh_module_full was missing!"
    fi
done
