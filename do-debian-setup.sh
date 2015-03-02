ssh -t root@$1 'apt-get update && \
                apt-get upgrade -y && \
                apt-get install -y -q curl git htop vim && \
                adduser deployer --gecos "" && \
                adduser deployer sudo'
ssh -t deployer@$1 'ssh-keygen'
scp ~/.ssh/id_rsa.pub deployer@$1:"~/.ssh/authorized_keys"
