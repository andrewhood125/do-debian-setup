ssh root@$1 'adduser deployer && adduser deployer sudo'
ssh deployer@$1 'ssh-keygen'
scp ~/.ssh/id_rsa.pub deployer@$1:"~/.ssh/authorized_keys"
