#!/usr/bin/env bash

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    cat << EOF
Easy template for starting simple scripts with documentation.
Usage:
     -h|--help                  Displays this help
     -v|--verbose               Displays verbose output
EOF
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parse_params() {
    local param
    while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
            i-\? | -h | --help)
                script_usage
                exit 0
                ;;
            -v | --verbose)
                verbose=true
                ;;
            *)
                script_exit "Invalid parameter was provided: $param" 1
                ;;
        esac
    done
}

# try to put it on the top of the script for easy modification.
# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {

    parse_params "$@"
    #lock_init system
    # here add your own commands and functions! 
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    main "$@"
fi

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
