#!/usr/bin/env bash
readonly DISTRI="stable" # "bookworm" "trixie" "bullseye" (oldoldstable oldstable stable testing sid)
readonly X="" # terminal ohne X 
# readonly X="gnome" # "gnome","" terminal ohne X 
readonly BOOT="toram" # "toram","" normal from usb ...
# readonly FUNC="iperf-master" # iperf-master,"" no special function / not so easy to implement without confusing?

#-------------------------------------------------------
[[ ${X} == "gnome" ]] && readonly GNOME=true || readonly GNOME=false
# [[ ${FUNC} == "iperf-master" ]] && readonly STARTIPERF=true || readonly STARTIPERF=false
#-------------------------------------------------------

function repair-sudo4ekf-after-install
{
cat > ${TDIR}/config/includes.chroot/usr/local/bin/sudo4ekf << "EOF"
echo 'ekf ALL=(ALL:ALL) NOPASSWD:ALL' > /tmp/ekf4testing && sudo cp /tmp/ekf4testing /etc/sudoers.d
EOF
sudo chmod a+x  ${TDIR}/config/includes.chroot/usr/local/bin/*
}

function cat-autostart-entry4gnome
{
cat > ${TDIR}/config/includes.chroot/etc/skel/.config/autostart/term.desktop << EOF
[Desktop Entry]
Type=Application
Exec=gnome-terminal 
# Exec=sudo gnome-terminal
# Exec=gnome-terminal -- run-parts autostart.dir
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=term
Name=term
Comment[en_US]=
Comment=
X-GNOME-Autostart-Delay=0
EOF
return 0
}

function auto-start4gnome
{
  mkdir -p ${TDIR}/config/includes.chroot/etc/skel/.config/autostart
  cat-autostart-entry4gnome
  mkdir -p ${TDIR}/config/includes.chroot/etc/skel/.config
  echo "yes" > ${TDIR}/config/includes.chroot/etc/skel/.config/gnome-initial-setup-done 
  return 0
}

function setup-calamares-installer
{
  mkdir -p ${TDIR}/config/includes.chroot/etc/calamares
  cp -r calamares/* ${TDIR}/config/includes.chroot/etc/calamares/
}

function live-config
{
( mkdir -p $TDIR && cd $TDIR && lb clean && lb config --mirror-bootstrap "http://deb.debian.org/debian/" --mirror-binary "http://deb.debian.org/debian/" --security false --updates "false" --distribution ${DISTRI} --cache-packages "false" --archive-areas "main non-free-firmware contrib" --bootappend-live "boot=live username=ekf ${BOOT}" )
# ( mkdir -p $TDIR && cd $TDIR && lb clean && lb config --mirror-bootstrap "http://deb.debian.org/debian/" --mirror-binary "http://deb.debian.org/debian/" --security false --updates "false" --distribution "bookworm" --debian-installer "live" --debian-installer-distribution "bookworm" --cache-packages "false" --archive-areas "main non-free-firmware contrib" --bootappend-live "boot=live username=ekf toram" )
return 0
}


function cat-autostart-network
{
cat > ${TDIR}/config/includes.chroot/etc/skel/autostart.dir/100-network << 'EOF'
#!/bin/bash
ip addr | grep "inet " | grep -v host
iperf3 -s
EOF
}

function add-iperf3-4gnome
{
  echo iperf3 >> ${TDIR}/config/package-lists/iperf.list.chroot

  mkdir -p ${TDIR}/config/includes.chroot/etc/skel/autostart.dir
  cat-autostart-network
  chmod a+x ${TDIR}/config/includes.chroot/etc/skel/autostart.dir/100-network
}

# readonly TDIR="live-${FUNC}-${X}4term-${BOOT}-${DISTRI}"
readonly TDIR="live-${X}4term-${BOOT}-${DISTRI}"

live-config

${GNOME} && echo task-gnome-desktop >> ${TDIR}/config/package-lists/desktop.list.chroot
${GNOME} && echo calamares-settings-debian calamares >> ${TDIR}/config/package-lists/installer.list.chroot
echo chrony >> ${TDIR}/config/package-lists/time.list.chroot

${GNOME} && auto-start4gnome 
${GNOME} && add-iperf3-4gnome
${GNOME} && setup-calamares-installer

# cp -r /usr/share/live/build/bootloaders/* ${TDIR}/config/bootloaders/
# cd  ${TDIR}/config/bootloaders
# echo "Modify timeout in all bootloaders." 
# bash
cp -r bootloaders/* ${TDIR}/config/bootloaders/
mkdir -p ${TDIR}/config/includes.chroot/etc/skel

function prog4ekf-misc
{
mkdir -p ${TDIR}/config/includes.chroot/usr/local/sbin
mkdir -p ${TDIR}/config/includes.chroot/usr/local/bin
cp sbin4ekf/* ${TDIR}/config/includes.chroot/usr/local/sbin
cp ekfuefi/* ${TDIR}/config/includes.chroot/usr/local/

cat > ${TDIR}/config/includes.chroot/usr/local/bin/prog4ekf << 'EOF'
board=$(sudo dmidecode -s baseboard-product-name) 
now=$(date +"%Y-%m-%d_%T")
sern=$(sudo dmidecode -s baseboard-serial-number)
bk=${board%-*}
# echo ${bk}-${sern}-${now}.BIN
sudo progspi -r file && mv file ${bk}_${sern}_${now}.BIN
bash 
cd /usr/local
case ${bk} in
  PC6|SC6)
    sudo progspi -os=0 ${board%-*}UEFI.BIN
    ;;
  *)
    sudo progspi ${board%-*}UEFI.BIN
    ;;
esac
exit 0
EOF
sudo chmod a+x  ${TDIR}/config/includes.chroot/usr/local/sbin/*
sudo chmod a+x  ${TDIR}/config/includes.chroot/usr/local/bin/*
}
prog4ekf-misc

function create-hist-misc
{
cat > ${TDIR}/config/includes.chroot/etc/skel/.bash_history << "EOF"
gsettings set org.gnome.SessionManager logout-prompt 'false'
gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop']"
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.SessionManager logout-prompt 'false' # Damit man auch mit dem Griff runterfahren kann ohne 60s zu warten.
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
sudo4ekf
sudo calamares 
EOF
}
create-hist-misc

function add2hist-efiboot-check
{
cat >> ${TDIR}/config/includes.chroot/etc/skel/.bash_history << "EOF"
sudo efibootmgr --label ekf4nvme --create --disk=/dev/nvme0n1p1 --part=1 --loader='EFI\debian\grubx64'
sudo efibootmgr --label deb4sda  --create --disk=/dev/sda --part=1 --loader='EFI\debian\grubx64.efi'
EOF
}
add2hist-efiboot-check

function add2history-prog
{
cat >> ${TDIR}/config/includes.chroot/etc/skel/.bash_history << "EOF"
history
sudo poweroff
sudo prog4ekf
EOF
}
add2history-prog

function auto-info-start-with-bashrc
{
cat > ${TDIR}/config/includes.chroot/etc/skel/.bashrc << 'EOF' # 
board=$(sudo dmidecode -s baseboard-product-name) 
#echo "Interrupt with <CTRL C>" 
echo "This is: "${board} 
echo "To update the UEFI BIOS please call: prog4ekf" 
echo "After this please call: sudo poweroff"
EOF
}

auto-info-start-with-bashrc

# sudo reboot
# sudo rtcwake -s 80 -m off  

echo libc6-i386 > ${TDIR}/config/package-lists/ekf.list.chroot # needed for progsi ....
echo efibootmgr pciutils usbutils > ${TDIR}/config/package-lists/debug.list.chroot # needed for progsi ....

repair-sudo4ekf-after-install

( cd ${TDIR} && lb build )

echo move ${TDIR}/live-image-amd64.hybrid.iso ${TDIR}.iso
mv ${TDIR}/live-image-amd64.hybrid.iso ${TDIR}.iso
ls -l ${TDIR}.iso 
