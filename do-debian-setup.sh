#! /usr/bin/env bash

if [[ "${1}x" == "x" ]] ; then
  echo -e "\nSYNOPSIS"
  echo -e "\t${BASH_SOURCE} [IP_ADDR | HOST_NAME]"
  exit 1
fi

ssh root@$1 'apt-get update && \
            apt-get upgrade -y && \
            apt-get install -y -q curl git htop vim && \
            adduser deployer --disabled-password --gecos "" && \
            adduser deployer sudo && \
            echo "deployer:password" | chpasswd && \
            passwd -e deployer && \
            mkdir /home/deployer/.ssh && \
            cp /root/.ssh/authorized_keys /home/deployer/.ssh/ && \
            chown -R deployer:deployer /home/deployer/.ssh && \
            chmod 600 /home/deployer/.ssh/authorized_keys && \
            chmod 700 /home/deployer/.ssh'

echo -e "\n\tYou may now login to $1 as deployer"
echo -e "\tyou must set your password on first login.\n"
echo -e "\t\tDefault password is \"password\"\n"
echo -e "\tssh deployer@$1"
