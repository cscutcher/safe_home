# Function to output list of all git config d files mentioned in either
#  .gitconfig or found in the folder $HOME/.gitconfig.d
GIT_CONFIG_D_INCLUDE="$HOME/.gitconfig.d.include"
function _list_all_git_config_d() {
    print -l $HOME/.gitconfig.d/**/*.gitconfig || return 1
}

function update_git_config_d(){
    log_debug "Updating git config d"
    ALL_CONFIG=$(_list_all_git_config_d) || return 1
    ALL_CONFIG=${ALL_CONFIG//$HOME/\~}
    ALL_CONFIG=$(sort -u <<< "$ALL_CONFIG")

    echo "[include]" > $GIT_CONFIG_D_INCLUDE
    for f in ${(f)ALL_CONFIG}; do
        echo "path = $f" >> $GIT_CONFIG_D_INCLUDE
    done
}

update_git_config_d
