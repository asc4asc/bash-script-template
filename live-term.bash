#!/usr/bin/env bash
readonly TDIR=live-term
# readonly export ARCHIVE_AREAS="main non-free non-free-firmware firmware-misc-non-free contrib" # does not help

mkdir -p ${TDIR}/config/includes.chroot/usr/local/sbin
mkdir -p ${TDIR}/config/includes.chroot/usr/local/bin
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

cat > ${TDIR}/config/includes.chroot/usr/local/bin/prog4ekf << 'EOF'
board=$(sudo dmidecode -s baseboard-product-name) 
sudo progspi /usr/local/${board%-*}UEFI.BIN
EOF

cat > ${TDIR}/config/includes.chroot/etc/skel/.bashrc << 'EOF'
board=$(sudo dmidecode -s baseboard-product-name) 
echo "Interrupt with <CTRL C>" 
echo "This is: "${board} 
echo "Info: "${board%-*} 
# sleep 10
# prog4ekf
# sudo reboot
EOF

chmod a+x ${TDIR}/config/includes.chroot/usr/local/sbin/* 
chmod a+x ${TDIR}/config/includes.chroot/usr/local/bin/* 
chmod a+x ${TDIR}/config/includes.chroot/etc/skel/progpc7 
chmod a+x ${TDIR}/config/includes.chroot/etc/skel/progsc5 

echo libc6-i386 > ${TDIR}/config/package-lists/ekf.list.chroot # needed for progsi ....

#mkdir -p ${TDIR}/config/includes.chroot/etc/default/
#cp /etc/default/grub ${TDIR}/config/includes.chroot/etc/default/

# ( mkdir -p $TDIR && cd $TDIR && lb clean && lb config --archive-areas "main non-free contrib") # install bullseye
( mkdir -p $TDIR && cd $TDIR && lb clean && lb config --mirror-bootstrap "http://deb.debian.org/debian/" --mirror-binary "http://deb.debian.org/debian/" --security false --updates "false" --distribution "bookworm" --debian-installer "live" --debian-installer-distribution "bookworm" --cache-packages "false" --archive-areas "main non-free-firmware contrib" --bootappend-live "boot=live username=ekf toram" )
#( mkdir -p $TDIR && cd $TDIR && lb clean && lb config --mirror-bootstrap "http://deb.debian.org/debian/" --mirror-binary "http://deb.debian.org/debian/" --security false --updates "false" --distribution "bookworm" --debian-installer "live" --debian-installer-distribution "bookworm" --cache-packages "false" --archive-areas "main non-free-firmware contrib" )
# echo more-packages >> ${TDIR}/config/package-lists/ekf.list.chroot # add
# echo debian-installer-launcher >> ${TDIR}/config/package-lists/installer.list.chroot

( cd ${TDIR} && lb build )

mv ${TDIR}/live-image-amd64.hybrid.iso ${TDIR}.iso

