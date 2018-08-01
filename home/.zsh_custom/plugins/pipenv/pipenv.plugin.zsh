# Enable completion for pipenv if available
if hash pipenv 2>/dev/null ; then
    eval "$(pipenv --completion)"
fi
