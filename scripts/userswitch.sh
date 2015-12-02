# configure iam user/key and sudoers
#useradd kpedersen -d /home/kpedersen -s /bin/bash
#usermod -G wheel,adm kpedersen
#mkdir -p /home/kpedersen/.ssh
#curl -s "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key/" -o /home/kpedersen/.ssh/authorized_keys
#chmod 700 /home/kpedersen/.ssh
#chmod 600 /home/kpedersen/.ssh/authorized_keys
#chown -R kpedersen:kpedersen /home/kpedersen/.ssh
#sed -i s/centos/kpedersen/g /etc/sudoers.d/*

# clean up bash history
cat /dev/null > /root/.bash_history
cat /dev/null > /home/centos/.bash_history
