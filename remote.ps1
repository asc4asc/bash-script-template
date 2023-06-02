$IP_REMOTE="172.21.120.76"

ssh root@$IP_REMOTE "sed -e 's/ekf ALL = ALL/ /' /etc/sudors > /tmp/sudoers && mv /tmp/sudoers /etc/sudoers ; echo nameserver 172.21.130.2 > /etc/resolv.conf ; cp -r .ssh /home/ekf/ && cd /home/ekf ; chown -R ekf.ekf .ssh && git clone https://github.com/asc4asc/bash-script-template.git"