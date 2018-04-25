function_exists() {
    declare -f -F $1 > /dev/null
    return $?
}

trim() { echo $1; }

# Append to paths
appendpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

