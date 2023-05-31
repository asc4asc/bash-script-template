#!/bin/bash
 [[ $USER == 'root' ]] && USER=ekf # add check if user ekf is present in this system
 sudo addgroup --group testsu && sudo adduser ${USER} testsu && sudo echo '%testsu ALL=(ALL:ALL) NOPASSWD:ALL' > /tmp/gen4testing && sudo cp /tmp/gen4testing /etc/sudoers.d
 # exit 0