# General useful helper functions
# This probably wont work in 'sh'?
save-command-run() {
    local OUTPUT_FILE="$1"
    local CMD=("$@")
    CMD=("${CMD[@]:1}")
    echo "> ${CMD[*]}" | tee "$OUTPUT_FILE"
    eval "${CMD[@]}"  2>&1 | tee -a "$OUTPUT_FILE"
}
