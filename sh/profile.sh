# Find main homeshick repo
# Try and put ALL OTHER constants elsewhere
export HOMESICK_REPOS="$HOME/.homesick/repos/"
export HOMESHICK_MAIN="${HOMESICK_REPOS}/safe_home/"

if [ ! -d $HOMESHICK_MAIN ]; then
    echo "ERROR: MISSING HOMESHICK MAIN" 1>&2
fi

export HOMESHICK_MAIN_SH="${HOMESHICK_MAIN}sh/"

if [ ! -d $HOMESHICK_MAIN_SH ]; then
    echo "ERROR NO HOMESHICK SH: EXPECT CHAOS" 1>&2
fi

LOG_CONTEXT="profile"

# Load logging helpers
if [ -e $HOMESHICK_MAIN_SH/modules/logging_functions.sh ]; then
    source $HOMESHICK_MAIN_SH/modules/logging_functions.sh
    log "Loaded logging."
else
    echo "ERROR NO LOGGING: EXPECT CHAOS" 1>&2
fi

# Load other helpers
for sh_module in \
        vars \
        common_sh_functions \
        dynamic_vars \
        profile_d \
        host_profiles \
        local_profile \
        bash \
        aliases \
    ; do
    sh_module_full="${HOMESHICK_MAIN_SH}modules/${sh_module}.sh"
    if [ -e $sh_module_full ]; then
        OLD_LOG_CONTEXT="$LOG_CONTEXT"
        log "Loading: $sh_module"
        LOG_CONTEXT="$sh_module"
        source $sh_module_full
        LOG_CONTEXT="$OLD_LOG_CONTEXT"
    else
        log_error "$sh_module_full was missing!"
    fi
done
