$IP_REMOTE="172.21.120.76"

ssh -o StrictHostKeyChecking=no root@$IP_REMOTE "sed -e  's/ekf   ALL = ALL/ /' /etc/sudoers > /tmp/sudoers && mv /tmp/sudoers /etc/sudoers ; ln -s /run/NetworkManager/resolv.conf /etc/resolv.conf  ; cp -r .ssh /home/ekf/ && cd /home/ekf ; chown -R ekf.ekf .ssh" 
# ssh -o StrictHostKeyChecking=no root@$IP_REMOTE "sed -e  's/ekf   ALL = ALL/ /' /etc/sudoers > /tmp/sudoers && mv /tmp/sudoers /etc/sudoers ; echo nameserver 172.21.130.2 > /etc/resolv.conf ; cp -r .ssh /home/ekf/ && cd /home/ekf ; chown -R ekf.ekf .ssh" 
ssh -o StrictHostKeyChecking=no ekf@$IP_REMOTE "git clone https://github.com/asc4asc/bash-script-template.git"
ssh -o StrictHostKeyChecking=no ekf@$IP_REMOTE 