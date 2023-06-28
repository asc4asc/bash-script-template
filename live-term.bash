#!/usr/bin/env bash
readonly TDIR=live-term
# readonly export ARCHIVE_AREAS="main non-free non-free-firmware firmware-misc-non-free contrib" # does not help

mkdir -p ${TDIR}/config/includes.chroot/usr/local/sbin
cp progspi ${TDIR}/config/includes.chroot/usr/local/sbin
cp PC7UEFI.BIN ${TDIR}/config/includes.chroot/usr/local/
cp SC5UEFI.BIN ${TDIR}/config/includes.chroot/usr/local/

mkdir -p ${TDIR}/config/includes.chroot/etc/skel/
cat > ${TDIR}/config/includes.chroot/etc/skel/progpc7 << EOF
sudo progspi /usr/local/PC7UEFI.BIN
EOF
cat > ${TDIR}/config/includes.chroot/etc/skel/progsc5 << EOF
sudo progspi /usr/local/SC5UEFI.BIN
EOF

chmod a+x ${TDIR}/config/includes.chroot/etc/skel/progpc7 
chmod a+x ${TDIR}/config/includes.chroot/etc/skel/progsc5 

# ( mkdir -p $TDIR && cd $TDIR && lb clean && lb config --archive-areas "main non-free contrib") # install bullseye
( mkdir -p $TDIR && cd $TDIR && lb clean && lb config --mirror-bootstrap http://deb.debian.org/debian/ --mirror-binary http://deb.debian.org/debian/ --security false --updates false --distribution bookworm --debian-installer live --debian-installer-distribution bookworm --cache-packages false --archive-areas "main non-free-firmware contrib" )
echo libc6-i386 >> ${TDIR}/config/package-lists/installer.list.chroot
echo debian-installer-launcher >> ${TDIR}/config/package-lists/installer.list.chroot

( cd ${TDIR} && lb build )

mv ${TDIR}/live-image-amd64.hybrid.iso ${TDIR}.iso

