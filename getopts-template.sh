#!/usr/bin/env bash
readonly SCRIPT_NAME="${0##*/}"

# DESC: Pretty print the provided string
# ARGS: $1 (required): Message to print (defaults to a green foreground)
#       $2 (optional): Colour to print the message with. This can be an ANSI
#                      escape code or one of the prepopulated colour variables.
#       $3 (optional): Set to any value to not append a new line to the message
# OUTS: None
function pretty_print() {
    if [[ $# -lt 1 ]]; then
        print 'Missing required argument to pretty_print()!' 
        exit 127
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

# DESC: Generic script initialisation
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: $orig_cwd: The current working directory when the script was run
#       $script_path: The full path to the script
#       $script_dir: The directory path of the script
#       $script_name: The file name of the script
#       $script_params: The original parameters provided to the script
#       $ta_none: The ANSI control code to reset all text attributes
# NOTE: $script_path only contains the path that was used to call the script
#       and will not resolve any symlinks which may be present in the path.
#       You can use a tool like realpath to obtain the "true" path. The same
#       caveat applies to both the $script_dir and $script_name variables.
# shellcheck disable=SC2034
function script_init() {
    # Useful variables
    readonly orig_cwd="$PWD"
    readonly script_params="$*"
    readonly script_path="${BASH_SOURCE[0]}"
    script_dir="$(dirname "$script_path")"
    script_name="$(basename "$script_path")"
    script_ext="${script_name##*-}"
    readonly script_ext script_dir script_name

    # Important to always set as we use it in the exit handler
    # shellcheck disable=SC2155
    readonly ta_none="$(tput sgr0 2> /dev/null || true)"
}

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    
    cat << EOF
${SCRIPT_NAME}: Easy template for starting simple scripts with documentation.
Usage:
     -h               Displays this help
     -v               Displays verbose output
     -d               Call the demo function
EOF
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parse_params() {
    while getopts "?hvd" arg; do
      case $arg in
        h | \?)
          script_usage
          exit 0 
          ;;
        v )
          verbose=true
          ;;

        d )
          demoflag=true
          ;;
        *) 
          printf '%s%b\n' "Invalid parameter was provided:" $param
          exit 127  
          ;;
      esac
    done
}

# try to put it on the top of the script for easy modification.
# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {

    script_init
    parse_params "$@"
    #lock_init system
    # here add your own commands and functions!
    verbose_print "Show the verbose function!"
    [ ${demoflag} ] && demo_function

    script_usage 

    if [ ${script_ext} == "reboot" ] 
    then
      echo Well done can use the extension: ${script_ext};
    else
      echo No known script extension ${script_ext}  
    fi
    
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 00 2> /dev/null); then
    main "$@"
fi

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
