adduser --disabled-password --gecos "" deployer
mkdir /home/deployer/.ssh
echo "$1" > /home/deployer/.ssh/authorized_keys
chmod 700 /home/deployer/.ssh
chmod 600 /home/deployer/.ssh/authorized_keys
chown deployer:deployer /home/deployer/.ssh /home/deployer/.ssh/authorized_keys
