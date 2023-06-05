#!/usr/bin/env bash

# DESC: Pretty print the provided string
# ARGS: $1 (required): Message to print (defaults to a green foreground)
#       $2 (optional): Colour to print the message with. This can be an ANSI
#                      escape code or one of the prepopulated colour variables.
#       $3 (optional): Set to any value to not append a new line to the message
# OUTS: None
function pretty_print() {
    if [[ $# -lt 1 ]]; then
        exit 'Missing required argument to pretty_print()!' 
    fi

    printf '%b' "$2"
    
    # Print message & reset text attributes
    if [[ -n ${3-} ]]; then
        printf '%s%b' "$1" "$ta_none"
    else
        printf '%s%b\n' "$1" "$ta_none"
    fi
}

# DESC: Only pretty_print() the provided string if verbose mode is enabled
# ARGS: $@ (required): Passed through to pretty_print() function
# OUTS: None
function verbose_print() {
    if [[ -n ${verbose-} ]]; then
        pretty_print "$@"
    fi
}

# DESC: 
# ARGS: $@ (required): 
# OUTS: None
function demo_function() {
    verbose_print "This verbose function is called to describe the use of this function"
    echo "Hi, demo_function in action!"
}

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    cat << EOF
Easy template for starting simple scripts with documentation.
Usage:
     -h|--help                  Displays this help
     -v|--verbose               Displays verbose output
     -d|--demo                  Call the demo function
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
            '-?' | -h | --help)
                script_usage
                exit 0
                ;;
            -v | --verbose)
                verbose=true
                ;;
            -d | --demo)
                demoflag=true
                ;;
            *)
                echo "Invalid parameter was provided: $param" 
                exit 126
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
    verbose_print "Show the verbose function!"
    [ ${demoflag} ] && demo_function
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    main "$@"
fi

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
