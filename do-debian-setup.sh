ssh -t root@$1 'apt-get update && \
                apt-get upgrade -y && \
                apt-get install -y -q curl git htop vim && \
                adduser deployer --gecos "" && \
                adduser deployer sudo && \
                mkdir /home/deployer/.ssh && \
                cp /root/.ssh/authorized_keys /home/deployer/.ssh/ && \
                chown -R deployer:deployer /home/deployer/.ssh && \
                chmod 600 /home/deployer/.ssh/authorized_keys && \
                chmod 700 /home/deployer/.ssh'
