#!/usr/bin/env bash
readonly DISTRI="stable" # "bookworm" "trixie" "bullseye" (oldoldstable oldstable stable testing sid)
readonly X="gnome" # "gnome","" terminal ohne X 
readonly BOOT="toram" # "toram","" normal from usb ...
# readonly FUNC="iperf-master" # iperf-master,"" no special function / not so easy to implement without confusing?

#-------------------------------------------------------
[[ ${X} == "gnome" ]] && readonly GNOME=true || readonly GNOME=false
# [[ ${FUNC} == "iperf-master" ]] && readonly STARTIPERF=true || readonly STARTIPERF=false
#-------------------------------------------------------

function make-autostart-entry4gnome
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
}

function auto-start4gnome
{
if ${GNOME}; then 
  mkdir -p ${TDIR}/config/includes.chroot/etc/skel/.config/autostart
  make-autostart-entry4gnome
else
  mkdir -p ${TDIR}/config/includes.chroot/etc/skel
fi
return 0
}

# readonly TDIR="live-${FUNC}-${X}4term-${BOOT}-${DISTRI}"
readonly TDIR="live-${X}4term-${BOOT}-${DISTRI}"

#echo ${GNOME}
#${GNOME} && echo ja
#${GNOME} || echo nein
# exit 0

# ( mkdir -p $TDIR && cd $TDIR && lb clean && lb config --mirror-bootstrap "http://deb.debian.org/debian/" --mirror-binary "http://deb.debian.org/debian/" --security false --updates "false" --distribution "bookworm" --debian-installer "live" --debian-installer-distribution "bookworm" --cache-packages "false" --archive-areas "main non-free-firmware contrib" --bootappend-live "boot=live username=ekf toram" )
( mkdir -p $TDIR && cd $TDIR && lb clean && lb config --mirror-bootstrap "http://deb.debian.org/debian/" --mirror-binary "http://deb.debian.org/debian/" --security false --updates "false" --distribution ${DISTRI} --cache-packages "false" --archive-areas "main non-free-firmware contrib" --bootappend-live "boot=live username=ekf ${BOOT}" )

${GNOME} && echo task-gnome-desktop >> ${TDIR}/config/package-lists/desktop.list.chroot
${GNOME} && echo calamares-settings-debian calamares >> ${TDIR}/config/package-lists/installer.list.chroot
echo chrony >> ${TDIR}/config/package-lists/time.list.chroot

auto-start4gnome 

echo iperf3 >> ${TDIR}/config/package-lists/iperf.list.chroot

if ${GNOME}; then 
mkdir -p ${TDIR}/config/includes.chroot/etc/skel/autostart.dir
cat > ${TDIR}/config/includes.chroot/etc/skel/autostart.dir/100-network << 'EOF'
#!/bin/bash
ip addr | grep "inet " | grep -v host
iperf3 -s
EOF

chmod a+x ${TDIR}/config/includes.chroot/etc/skel/autostart.dir/100-network

mkdir -p ${TDIR}/config/includes.chroot/etc/calamares
cp -r calamares/* ${TDIR}/config/includes.chroot/etc/calamares/
fi

# cp -r /usr/share/live/build/bootloaders/* ${TDIR}/config/bootloaders/
# cd  ${TDIR}/config/bootloaders
# echo "Modify timeout in all bootloaders." 
# bash
cp -r bootloaders/* ${TDIR}/config/bootloaders/

mkdir -p ${TDIR}/config/includes.chroot/usr/local/sbin
mkdir -p ${TDIR}/config/includes.chroot/usr/local/bin
cp progspi ${TDIR}/config/includes.chroot/usr/local/sbin
# cp PC7UEFI.BIN ${TDIR}/config/includes.chroot/usr/local/
# cp SC5UEFI.BIN ${TDIR}/config/includes.chroot/usr/local/
cp ekfuefi/* ${TDIR}/config/includes.chroot/usr/local/


#mkdir -p ${TDIR}/config/includes.chroot/etc/skel/
#cat > ${TDIR}/config/includes.chroot/etc/skel/progpc7 << EOF
#sudo progspi /usr/local/PC7UEFI.BIN
#EOF
#cat > ${TDIR}/config/includes.chroot/etc/skel/progsc5 << EOF
#sudo progspi /usr/local/SC5UEFI.BIN
#EOF

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

cat > ${TDIR}/config/includes.chroot/etc/skel/.bash_history << 'EOF'
history
sudo poweroff
sudo prog4ekf
EOF
# sudo4ekf
# sudo calamares 

if ${GNOME}; then 
mkdir -p ${TDIR}/config/includes.chroot/etc/skel/.config
cat > ${TDIR}/config/includes.chroot/etc/skel/.config/gnome-initial-setup-done << 'EOF'
yes
EOF
fi

cat > ${TDIR}/config/includes.chroot/usr/local/bin/sudo4ekf << "EOF"
echo 'ekf ALL=(ALL:ALL) NOPASSWD:ALL' > /tmp/ekf4testing && sudo cp /tmp/ekf4testing /etc/sudoers.d
EOF

cat > ${TDIR}/config/includes.chroot/etc/skel/.bashrc << 'EOF' # 
board=$(sudo dmidecode -s baseboard-product-name) 
#echo "Interrupt with <CTRL C>" 
echo "This is: "${board} 
echo "To update the UEFI BIOS please call: prog4ekf" 
echo "After this please call: sudo poweroff"
EOF

#echo "Info: "${board%-*} 
# sleep 30
# prog4ekf
# sudo reboot
# sudo rtcwake -s 80 -m off  
# EOF

chmod a+x ${TDIR}/config/includes.chroot/usr/local/sbin/* 
chmod a+x ${TDIR}/config/includes.chroot/usr/local/bin/* 
# chmod a+x ${TDIR}/config/includes.chroot/etc/skel/progpc7 
# chmod a+x ${TDIR}/config/includes.chroot/etc/skel/progsc5 

# mkdir -p ${TDIR}/config/includes.chroot/etc/default/
# cp /etc/default/grub ${TDIR}/config/includes.chroot/etc/default/

# echo more-packages >> ${TDIR}/config/package-lists/ekf.list.chroot # add
# echo debian-installer-launcher >> ${TDIR}/config/package-lists/installer.list.chroot

echo libc6-i386 > ${TDIR}/config/package-lists/ekf.list.chroot # needed for progsi ....
echo pciutils usbutils > ${TDIR}/config/package-lists/debug.list.chroot # needed for progsi ....

( cd ${TDIR} && lb build )

echo move ${TDIR}/live-image-amd64.hybrid.iso ${TDIR}.iso
mv ${TDIR}/live-image-amd64.hybrid.iso ${TDIR}.iso
ls -l ${TDIR}.iso 
