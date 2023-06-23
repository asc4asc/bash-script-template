#!/usr/bin/env bash
readonly TDIR=live-xterm

( mkdir -p $TDIR && cd $TDIR && lb clean && lb config )

echo task-gnome-desktop >> ${TDIR}/config/package-lists/desktop.list.chroot
echo debian-installer-launcher >> ${TDIR}/config/package-lists/installer.list.chroot

mkdir -p ${TDIR}/config/includes.chroot/etc/skel/.config/autostart
cat > ${TDIR}/config/includes.chroot/etc/skel/.config/autostart/term.desktop << EOF
[Desktop Entry]
Type=Application
# Exec=gnome-terminal 
Exec=sudo gnome-terminal
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

( cd ${TDIR} && lb build )

mv ${TDIR}/live-image-amd64.hybrid.iso ${TDIR}.iso

