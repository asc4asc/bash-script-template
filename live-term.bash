#!/usr/bin/env bash
readonly TDIR=live-xterm

( mkdir -p $TDIR && cd $TDIR && lb clean && lb config )

echo debian-installer-launcher >> ${TDIR}/config/package-lists/installer.list.chroot

( cd ${TDIR} && lb build )

mv ${TDIR}/live-image-amd64.hybrid.iso ${TDIR}.iso

