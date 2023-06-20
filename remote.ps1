# fai debian me / User ekf / Password Admin123 / github user asc4asc / zusaetzlich paket git  
# curl "https://fai-project.org/cgi/faime.cgi?type=install;username=ekf;userpw=Admin123;gittype=github;gituser=asc4asc;partition=ONE;keyboard=us;suite=bookworm;desktop=GNOME;cl5=SSH_SERVER;cl6=STANDARD;cl7=NONFREE;addpkgs=git;email=asc%40ekf.de;rclocal=1;cl8=REBOOT;sbm=2"

$IP_REMOTE="172.21.120.76"

ssh -o StrictHostKeyChecking=no root@$IP_REMOTE "echo 'ekf ALL=(ALL:ALL) NOPASSWD:ALL' > /tmp/sudo4ekf && sudo cp /tmp/sudo4ekf /etc/sudoers.d && sed -e  's/ekf   ALL = ALL/ /' /etc/sudoers > /tmp/sudoers && mv /tmp/sudoers /etc/sudoers ; ln -s /run/NetworkManager/resolv.conf /etc/resolv.conf  ; cp -r .ssh /home/ekf/ && cd /home/ekf ; chown -R ekf:ekf .ssh" 
# ssh -o StrictHostKeyChecking=no root@$IP_REMOTE "sed -e  's/ekf   ALL = ALL/ /' /etc/sudoers > /tmp/sudoers && mv /tmp/sudoers /etc/sudoers ; echo nameserver 172.21.130.2 > /etc/resolv.conf ; cp -r .ssh /home/ekf/ && cd /home/ekf ; chown -R ekf.ekf .ssh" 
ssh -o StrictHostKeyChecking=no ekf@$IP_REMOTE "git clone https://github.com/asc4asc/bash-script-template.git"
ssh -o StrictHostKeyChecking=no ekf@$IP_REMOTE 