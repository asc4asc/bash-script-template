#!/usr/bin/env bash

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    cat << EOF
Helper script that prepare a new installed Ubuntu .... to work as a test system with boot cycles.

The test system is a ubuntu 22.04 LTS. sudo must work.

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
            \? | -h | --help)
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

# powercycle oder reboot oder mix am Namen fest machen.
# * test4me-reboot
# * test4me-powercycle
readonly autostartdir="${HOME}/autostart.dir"
function gen_sudo()
{
    [[ $USER == 'root' ]] && USER=ekf # add check if user ekf is present in this system
    sudo addgroup --group testsu && sudo adduser ${USER} testsu && echo '%testsu ALL=(ALL:ALL) NOPASSWD:ALL' > /tmp/gen4testing && sudo cp /tmp/gen4testing /etc/sudoers.d
}

function place_bin()
# ~/autostart.dir/<link>named>test4me-powercycle to /usr/local/bin/test4me oder test4me-reboot
{
    sudo cp ${1} /usr/local/bin/
    sudo chmod a+x /usr/local/bin/${1}
}

function gen_autoterm()
{
    mkdir ${HOME}/.config/autostart

    cat << EOF  > ${HOME}/.config/autostart/term.desktop
[Desktop Entry]
Type=Application
# Exec=gnome-terminal 
# Exec=sudo gnome-terminal
Exec=gnome-terminal -- run-parts autostart.dir
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=term
Name=term
Comment[en_US]=
Comment=
X-GNOME-Autostart-Delay=0
EOF
}

function gen_login()
{
    sudo cat << EOF  > /tmp/custom.conf
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=${USER}
EOF
sudo cp /tmp/custom.conf /etc/gdm3/custom.conf
}


function make_autostart()
{
    mkdir -p ${autostartdir}
    ln -s /usr/local/bin/test4me ${autostartdir}/test4me-reboot
    gen_login  
    gen_autoterm
}

# try to put it on the top of the script for easy modification.
# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {

    parse_params "$@"
    #lock_init system
    # here add your own commands and functions! 
    gen_sudo
    place_bin test4me
    make_autostart

echo "Fuer Graphische Oberflaeche:"
echo "Settings -> User Auomatic login [enable]"
}

# Invoke main with args if not sourced
if ! (return 0 2> /dev/null); then
    main "$@"
fi



