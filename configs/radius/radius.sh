ifup -a

mkdir -p /home/user/.ssh
touch /home/user/.ssh/authorized_keys
chmod 600 /home/user/.ssh/authorized_keys
cat /tmp/authorized_keys > /home/user/.ssh/authorized_keys
chown -R user:user /home/user/.ssh

echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "user:test" | chpasswd

/usr/sbin/radiusd -x
