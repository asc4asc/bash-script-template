#!/usr/bin/env bash
# powercycle oder reboot oder mix am Namen fest machen.
# * test4me-reboot
# * test4me-powercycle

function gen_sudo()
{
[[ $USER == 'root' ]] && USER=ekf # add check if user ekf is present in this system
sudo addgroup --group testsu && sudo adduser ${USER} testsu && sudo echo '%testsu ALL=(ALL:ALL) NOPASSWD:ALL' > /tmp/gen4testing && sudo cp /tmp/gen4testing /etc/sudoers.d
}

function place_bin()
# ~/autostart.dir/<link>named>test4me-powercycle to /usr/local/bin/test4me oder test4me-reboot
{
cp testme /usr/local/bin/
sudo chmod a+x /usr/local/bin/test4me
}

function make_autostart()
{
mkdir autostart.dir
ln -s /usr/local/bin/testme ~/autostart.dir/testme-reboot

# man braucht auch noch:
# ~/.config/autostart/term.desktop
cp term.autostart ~/.config/autostart
)

gen_sudo
place_bin
make_autostart

echo "Fuer Graphische Oberflaeche:"
echo "Settings -> User Auomatic login [enable]"

# Weitere Ideen fuer die Zukunft.
# * test4me-1pow-1reboot
