#!/bin/bash
 [[ $USER == 'root' ]] && USER=ekf
 sudo addgroup --group testsu && sudo adduser ${USER} testsu && sudo echo '%testsu ALL=(ALL:ALL) NOPASSWD:ALL' > /tmp/gen4testing && sudo cp /tmp/gen4testing /etc/sudoers.d
 exit 0