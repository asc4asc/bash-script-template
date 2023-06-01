#!/usr/bin/env bash
# powercycle oder reboot oder mix am Namen fest machen.
# * test4me-reboot
# * test4me-powercycle

readonly autostartdir="${HOME}autostart.dir"
function gen_sudo()
{
[[ $USER == 'root' ]] && USER=ekf # add check if user ekf is present in this system
sudo addgroup --group testsu && sudo adduser ${USER} testsu && sudo echo '%testsu ALL=(ALL:ALL) NOPASSWD:ALL' > /tmp/gen4testing && sudo cp /tmp/gen4testing /etc/sudoers.d
}

function place_bin()
# ~/autostart.dir/<link>named>test4me-powercycle to /usr/local/bin/test4me oder test4me-reboot
{
cp ${1} /usr/local/bin/
sudo chmod a+x /usr/local/bin/${1}
}

function gen_autoterm()
{
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

function make_autostart()
{
mkdir ${autostartdir}
ln -s /usr/local/bin/testme ${autostartdir}/testme-reboot

# man braucht auch noch:
# ~/.config/autostart/term.desktop
cp term.desktop ${HOME}/.config/autostart
# gen_autoterm
}

gen_sudo
place_bin test4me
make_autostart

echo "Fuer Graphische Oberflaeche:"
echo "Settings -> User Auomatic login [enable]"

# Weitere Ideen fuer die Zukunft.
# * test4me-1pow-1reboot